# A full data pipeline: S3, AWS Glue and Snowflake 🔥

In short:

1. Transform raw CSV in S3 into JSON using AWS Glue.
2. Load data into Snowflake.

# Visualization of the process 😍

![Screenshot 2024-01-19 at 19 37 56](https://github.com/narutosstudent/aws-glue-etl-snowflake/assets/49603590/3e68b77a-95b5-422a-b05e-85a5b707478f)

# Chronologically explained ♻️

1. **S3 Bucket Creation**: Initiate an S3 bucket named `tiger-kun-data-center` using Terraform. This bucket stores the raw data file `customers.csv`.

2. **Data Upload**: Utilize AWS CLI to upload `customers.csv` into the `/raw` directory of the S3 bucket.

3. **AWS Glue Catalog Database Setup**: Establish an AWS Glue Catalog Database titled `customers_database` for metadata storage.

4. **AWS Glue Crawler Configuration**: Implement an AWS Glue Crawler linked to the `customers_database`. The crawler is assigned a role (`NewAWSGlueServiceRole`) with permissions to access and modify the S3 bucket. It targets the path `s3://tiger-kun-data-center/raw/customers.csv` to retrieve metadata and create a corresponding table in the database.

![Screenshot 2024-01-19 at 06 20 37](https://github.com/narutosstudent/aws-glue-etl-snowflake/assets/49603590/01136276-bc58-4697-8827-1c1b12c47750)

5. **AWS Glue Job Setup**: In AWS Glue Studio, configure the ETL job using a visual interface. Customize the script to rename the transformed output to `customers.json` (otherwise Glue will give it a random name) and modify the job settings to use specific S3 paths (`/job/sparkHistoryLogs/`, `/job/scripts/`, `/job/temporary/`) for storing job-related data. Ensure the job's output is not compressed.

![Screenshot 2024-01-19 at 06 42 58](https://github.com/narutosstudent/aws-glue-etl-snowflake/assets/49603590/769bcc0a-a11b-469a-8d88-b33f92018679)

6. **Running the AWS Glue Job**: Execute the job to process and transform data, resulting in `customers.json` being stored in the `/transformed` directory of the S3 bucket.

7. **Snowflake Infrastructure Provisioning**: Use Terraform to deploy all necessary Snowflake resources, including a warehouse (`customers_wh`), database (`customers_db`), and schema (`customers_schema`). 

8. **Snowflake External Stage Setup**: Create a Snowflake stage for the S3 bucket's transformed data path. This is facilitated by an IAM user with a policy granting specific permissions to access the relevant S3 paths.

9. **Data Loading into Snowflake**: In the Snowflake UI, execute a COPY command to load data from the S3 stage into the Snowflake table (`customers`). This command is run within the `customers_wh` warehouse and requires specifying JSON file format and matching column names case-sensitively.

![Screenshot 2024-01-19 at 18 22 12](https://github.com/narutosstudent/aws-glue-etl-snowflake/assets/49603590/86d18bc8-a0af-4442-8cf8-fbff644cd3a2)

# Debugging stories I still remember lmfao 😄

## AWS Glue jobs failing

AWS Glue needs to store temporary data in s3 when it is running its jobs, e.g., the script file.

These were stored in a new bucket whose name was randomly created by AWS Glue.

This is a different path than the role `NewAWSGlueServiceRole` which gives AWS Glue permission to touch files in my bucket.

So, for example, what was in the script, which was located in the randomly created bucket, didn't have access, so the job ended up failing.

I fixed this by configuring the paths in the advanced properties section of the AWS Glue job details.

![Screenshot 2024-01-19 at 18 28 36](https://github.com/narutosstudent/aws-glue-etl-snowflake/assets/49603590/eeceba75-1f13-4a57-9453-fb449b2b4bf0)

## Snowflake account where lol

Ok, this wasn't really a debugging story, but it was a bit tricky to find my account identifier in Snowflake. [Reading the docs](https://docs.snowflake.com/en/user-guide/admin-account-identifier), it's the part before the snowflakecomputing URL.

So, here is the funny part: Snowflake has a button with a tooltip saying Copy Acccount Identifier. So that gives you `org.accountid` I think.

But it is definitely not the account identifier mentioned in the docs. If you want to find that one, you've to click copy URL, which gives you something like this: `https://{account-identifier}.snowflakecomputing.com`. That account identifier isn't the same as what the button tells you to copy.

So for a while, Terraform Cloud kept failing to authenticate to Snowflake.

At least the error message was good enough compared to the next story 😅

## Creating Snowflake Stage keeps failing

Creating an external snowflake stage for the S3 bucket's transformed data path kept failing when trying to provision the resource with `terraform apply`.

Now, I had done everything right:

```hcl
resource "snowflake_stage" "s3_stage" {
  name     = "s3_stage"
  database = snowflake_database.customers_database.name
  schema   = snowflake_schema.customers_schema.name
  url      = "s3://${var.s3_data_lake_name}/${var.s3_transformed_data_folder}/"

  file_format = "JSON"

  credentials = "AWS_KEY_ID='${var.snowflake_iam_user_key_id}' AWS_SECRET_KEY='${var.snowflake_iam_user_key_secret}'"

}
```

But it kept failing, and it gave a [generic error message](https://github.com/Snowflake-Labs/terraform-provider-snowflake/issues/2188), so you couldn't really pin down what was going wrong.

[Referring to the documentation of the Terraform Snowflake Provider, I should've done everything right](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/stage).

Honestly, I started to feel hopeless. 😂

Like the error message is generic, and I'm literally doing what the docs tell me to.

And then I found this [workaround](https://github.com/Snowflake-Labs/terraform-provider-snowflake/issues/265#issuecomment-736864158).

We gotta do it this way when specifying the format of file: `file_format = "TYPE = JSON"`

So relieved. 😮‍💨

# How could this be improved?

This is what you would typically call Batch Processing.

Not data that gets sent in real-time, but rather done in a schedule.

So, how could I improve this project?

In a realistic scenario, you would want to configure the [Glue job in terraform too](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_job). This would likely run on a schedule.

When configuring the Glue Job, you can point to a script as well. So we'd include the scripting there. This involves the post-script once the job is done that turns the transformed path into `customers.json`.

We'd probably also not need to configure the AWS Glue Job's advanced properties stuff like I did.

# Pre study

Before embarking on this project, I did some pre study.

This involved learning more about Snowflake and AWS Glue.

Snowflake's hands on tutorial was amazing.

Concise and practical, I loved it!

Notes: https://github.com/narutosstudent/snowflake-aws-glue-data-notes
