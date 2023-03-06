#################################################
# Sent by: Contact MS
#################################################

resource "sparkpost_template" "contact-form-confirmation-fr" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Merci d'avoir contacté Global Forest Watch"
  name                   = "Contact Form confirmation FR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/contact-form-confirmation-fr.html")
}

resource "sparkpost_template" "contact-form-confirmation-pt" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Obrigado por entrar em contato com a Global Forest Watch"
  name                   = "Contact Form confirmation PT"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/contact-form-confirmation-pt.html")
}

resource "sparkpost_template" "contact-form" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "{{subject}}"
  name                   = "Contact form submission EN (Internal)"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/contact-form.html")
}

resource "sparkpost_template" "contact-form-confirmation-zh" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "感谢您联系全球森林监察"
  name                   = "Contact Form confirmation ZH"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/contact-form-confirmation-zh.html")
}

resource "sparkpost_template" "contact-form-confirmation-es" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_subject        = "Gracias por mandar un mensaje a Global Forest Watch"
  name                   = "Contact Form confirmation ES"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/contact-form-confirmation-es.html")
}

resource "sparkpost_template" "contact-form-confirmation-id" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Terima kasih telah menghubungi Global Forest Watch"
  name                   = "Contact Form confirmation ID"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/contact-form-confirmation-id.html")
}

resource "sparkpost_template" "contact-form-confirmation-en" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_subject        = "Thank you for contacting Global Forest Watch."
  name                   = "Contact Form confirmation EN"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/contact-form-confirmation-en.html")
}

resource "sparkpost_template" "request-webinar-en" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_subject        = "Webinar request from Global Forest Watch user."
  name                   = "Webinar request EN"
  options_click_tracking = false
  options_open_tracking  = false
  options_transactional  = true
  published              = true
  template_id            = "request-webinar-en"
  content_html           = file("${path.module}/templates/request-webinar-en.html")
}
