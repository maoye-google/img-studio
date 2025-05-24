# Infrastructure setup guide for ImgStudio (Click-to-Deploy using Terraform)

## 0\\ Get access to **Imagen models**

- **In general, for Vertex** in the console
  - Go to `Vertex AI` \> `Enable all recommended APIs` (they should include: **Vertex AI API, Cloud Storage API)**
  - Make sure the Vertex Service Account exists in your project `service-PROJECT_NUMBER@gcp-sa-aiplatform.iam.gserviceaccount.com`
- **For Imagen Generation:**
  - Models are now in public GA, **Imagen 3 Generate** (`imagen-3.0-generate-002`) and **Imagen 3 Generate Fast** (`imagen-3.0-fast-generate-001`)
  - **For people generation** (adult and/ or children), you now need to fill out [this form](https://docs.google.com/forms/d/e/1FAIpQLSduBp9w84qgim6vLriQ9p7sdz62bMJaL-nNmIVoyiOwd84SMw/viewform) to get access.
- **For Imagen > Editing & Customization**
  - You can fill out [this form](https://docs.google.com/forms/d/e/1FAIpQLScN9KOtbuwnEh6pV7xjxib5up5kG_uPqnBtJ8GcubZ6M3i5Cw/viewform) to get access to the Preview feature (name: `imagen-3.0-capability-001`)
  - You will also need the **Vertex Image Segmentation model** when using editing, fill out [this form](https://docs.google.com/forms/d/e/1FAIpQLSdzIR1EeQGFcMsqd9nPip5e9ovDKSjfWRd58QVjo1zLpfdvEg/viewform?resourcekey=0-Pvqc66u-0Z1QmuzHq4wLKg&pli=1) to get access (name: `image-segmentation-001`)
- **For Veo > Generation**
  - Model for text-to-video is now in public GA, **Veo 2 Generate** (`veo-2.0-generate-001`)
- **For Veo > Advanced**
  - For **Image-to-video** (`veo-2.0-generate-001`) & advanced features (`veo-2.0-generate-exp`: interpolation, camera preset), you need to fill out [this form](https://docs.google.com/forms/d/e/1FAIpQLSciY6O_qGg2J0A8VUcK4egJ3_Tysh-wGTl-l218XtC0e7lM_w/viewform)

## 1\\ Run **prereq.sh** script

- **Specifications:** This script will automatically confirm your target GCP project, create GCS Bucket (for Terraform Status storage) and necessary Service Accounts, enable necessary APIs, and grant necessary permissions.
- **How to Run**
  - Locate yourself to the project root folder, and then run the script like "sh prereq.sh"

## 2\\ Double check **Oauth Brand** in your target project

- **Background:** 
  - ImgStudio provides Https access with Oauth authentication. This requires you to finish oauth brand setup in your target application. 
  - However, each GCP program can have only 1 Oauth Brand registered, and the CICD process (we use Terraform this time) cannot programmatically update/delete the Oauth Brand information.
  - So in case you have already created Oauth Brand in your project with different information with different value that we will use to deploy ImgStudio, it will break Terraform automation.
  - To prevent this issue, you have to either (a) manually update Oauth Brand via GCP Web Console to use latest information, or (b) update CICD configuration (cloudbuild_*.yaml) to use same information, so Terraform will skip the update job.

- **How to Run**
  - You can run this script to get current Oauth Brand information : `sh script/show_current_oauth_brand.sh <project_id>`

## 3\\ Choose CICD option and Run the auto-deployment process

- **Specifications:** 
  - We prepared three CICD options, they are :
    - option-1: **clean deployment**. This option uses `cloudbuild_clean_run.yaml` config file. It will first destroy all existing cloud components, re-build the container, and then create the whole infrastructure again. Since it does not use zero downtime upgrade technology, you will experience temporary service down in this pattern. The already uploaded photos will keep there. We recommend that you use this option when it is your FIRST time to deploy imgstudio in a new GCP project.
    - option-2: **continuous deployment**. This option uses `cloudbuild_continuous_run.yaml` config file. It will NOT destroy the current infrastructure, but let Terraform to calculate a better plan to only update those components who have configuration change. The Cloud Run deployment in this option does not introduce service down time. We recommend that you use this option for deployment from the second time.
    - option-3: **destroy**. This option uses `cloudbuild_destroy.yaml` config file. It will destroy all the infrastructure components that are ever created by Terraform in this project. Since GCS buckets will also be deleted, we recommend you use this option with enough caution.
  - **High Level Build Steps**:
    - Step-0: Build imgstudio docker image
    - Step-1: Push docker image to artifact registry
    - Step-2: [Only in Clean Deploy option] Check cucrrent Oauth Brand status, and create a new one if not exist
    - Step-3: Terraform Initialization
    - Step-4: [Only in Clean Deploy option] Destroy existing Terraform records for Oauth Brand
    - Step-5: [Only in Clean Deploy option] Reload actual Oauth Brand information into Terraform
    - Step-6: Apply all expected changes to Infrastructure by Terraform automatically
    - Step-7: Extract the external LB's IP address, and create DNS setup command
  - **Necessary Paramters**:
    - Basically, you need to manually update these values inside your <cloudbuild_*.yaml> file
        - _APP_NAME: 'imgstudio' # Use your value here. Must be [lower letters, numbers, -,_]. You can also choose to pass the value when running gcloud command
        - _APP_REGION: 'asia-northeast1' # Use your preferred regions. You can also choose to pass the value when running gcloud command
        - _OAUTH_ADMIN_EMAIL: '${data.google_project.project.number}-compute@developer.gserviceaccount.com' # Use your actual email here. Make sure this email is exactly same with your current Oauth Brand email setting.
    - See the `substitutions` part inside your config yaml file for details

- **How to Run**
  - Locate yourself in the project root folder, then run `gcloud builds submit . --config=<cloudbuild_*.yaml>`
  - Instead, if you want to manually specify a new APP_NAME (and/or REGION), you can use `--substitutions` option.
    - Example Command: `gcloud builds submit . --config=<cloudbuild_*.yaml> --substitutions=_APP_NAME=<app_name_in_lower_case>,_OAUTH_ADMIN_EMAIL=<your_admin_email>`
  - Please be aware that the clean deployment might take 5 minutes+ to run.
  - During the execution, you can check the Cloud Build and Terraform Log via CLI, or watch streaming logs in Cloud Build web UI.

## 4\\ Update **DNS Record** Configuration

- **Specification**
  - Terraform will print out "external LB's IP address" and "expected domain name" which needs to be the one we used to create HTTPS certificate (this step is included in above stage)

- **How to Run**
  - The Terraform Log will output these two values like follows:
    - `expected_customer_domain = "imgstudio.maoye.demo.altostrat.com"`
    - `load_balancer_external_ip = "34.117.202.144"`
  - If IP is not there, you need to manually check it. For example, open `Load Balancer` page in GCP, and check the assigned external IP address for your target LB.
  - How to add new DNS Record (mapping the above domain name to the new IP) depends on how you manage your root DNS.
  - After you manually add DNS record, the System will take some time (usually several minutes) to verify the Domain ownership, and finish SSL provision process. Before that is done, you will not be able to open ImgStudio's web UI. You can check Https provision status via GCP console too.


## Enjoy it !

- **Command Example**
  - gcloud builds submit . --config=cloudbuild_continuous_run.yaml --substitutions=_APP_NAME=imgstudio,_OAUTH_ADMIN_EMAIL=admin@maoye.altostrat.com

> ###### _This is not an officially supported Google product. This project is not eligible for the [Google Open Source Software Vulnerability Rewards Program](https://bughunters.google.com/open-source-security)._
