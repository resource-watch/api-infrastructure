# Email templates for the RW API

This file aims to cover the basics of how to edit a Sparkpost template through the Terraform code in this folder.

Here's what you need to know:

- `versions.tf` and `variable.tf` are Terraform-specific configuration. Ignore these two.
- The other `.tf` files each correspond roughly to a RW/FW API microservice (areas, contact, etc). 
The emails sent by each MS can be found in the corresponding file. If you are looking for an existing template to edit, this gives you a narrower search field. If you are creating a new template, add it to the corresponding file. If you are adding a template for a new microservice, such create a new `.tf` file named accordingly, and use that. 
- Each of these `.tf` files contains multiple, similarly structured Terraform `resource` blocks  of type [sparkpost_template](https://registry.terraform.io/providers/SurveyMonkey/sparkpost/latest/docs/resources/template). If you are creating a new template, you need to duplicate and modify one of these blocks. If you are modifying an existing template, and want to change anything other that the email body, look for the relevant block and edit it.
- Each of these `resource` blocks references a file in `content_html`. Those files can be found inside the `templates` folder. While they have the `.html` extension, they are not pure HTML files, and instead use Sparkpost template syntax, which allows for basic logic and variables. If you are creating a new template, you need to create a new/duplicate an existing file, edit it accordingly, and reference it in the new `resource` block you created in the previous step. If you are looking to edit an existing template, modify the corresponding file.
- If you are editing an existing template and want preview your changes, you can copy-paste the full content of your `.html` file into the Sparkpost UI, and use its native preview/test functionalities.
- Once you are done, you need to follow the standard procedure to push these changes to Github, through a Pull Request. Once the Pull Request goes through approval and is merged to the `production` branch, it will be automatically applied to Sparkpost.