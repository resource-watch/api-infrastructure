#################################################
# Sent by: Subscriptions MS (through the Mail MS)
#################################################

resource "sparkpost_template" "glad-updated-notification-id" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Peringatan perubahan hutan"
  name                   = "GLAD Notifications v2 ID"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/glad-updated-notification-id.html")
}

resource "sparkpost_template" "glad-updated-notification-es-mx" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Alertas de deforestación"
  name                   = "GLAD Notifications v2 ES-MX"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/glad-updated-notification-es-mx.html")
}

resource "sparkpost_template" "glad-updated-notification-fr" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Alerte d'évolution forestière"
  name                   = "GLAD Notifications v2 FR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/glad-updated-notification-fr.html")
}

resource "sparkpost_template" "glad-updated-notification-en" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Forest change alert"
  name                   = "GLAD Notifications v2 EN"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/glad-updated-notification-en.html")
}

resource "sparkpost_template" "glad-updated-notification-pt-br" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Alertas de desmatamento"
  name                   = "GLAD Notifications v2 PT-BR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/glad-updated-notification-pt-br.html")
}

resource "sparkpost_template" "glad-updated-notification-zh" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "森林变化预警"
  name                   = "GLAD Notifications v2 ZH"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/glad-updated-notification-zh.html")
}

resource "sparkpost_template" "forest-fires-notification-viirs-fr" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Alertes incendies"
  name                   = "Forest Fires Notification FR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/forest-fires-notification-viirs-fr.html")
}
resource "sparkpost_template" "forest-fires-notification-viirs-en-updated" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Fire Alerts"
  name                   = "Forest Fires Notification EN (UPDATED)"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/forest-fires-notification-viirs-en-updated.html")
}
resource "sparkpost_template" "forest-fires-notification-viirs-es-mx" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Alertas de incendio"
  name                   = "Forest Fires Notification ES-MX"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/forest-fires-notification-viirs-es-mx.html")
}

resource "sparkpost_template" "forest-fires-notification-viirs-id" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Peringatan kebakaran"
  name                   = "Forest Fires Notification ID"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/forest-fires-notification-viirs-id.html")
}
resource "sparkpost_template" "forest-fires-notification-viirs-pt-br" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Alertas de incêndio"
  name                   = "Forest Fires Notification PT-BR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/forest-fires-notification-viirs-pt-br.html")
}

resource "sparkpost_template" "forest-fires-notification-viirs-en" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Fire Alerts"
  name                   = "Forest Fires Notification EN"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/forest-fires-notification-viirs-en.html")
}

resource "sparkpost_template" "forest-fires-notification-viirs-zh" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "火灾警报"
  name                   = "Forest Fires Notification ZH"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/forest-fires-notification-viirs-zh.html")
}

resource "sparkpost_template" "monthly-summary-es-mx" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Resumen mensual de alertas"
  name                   = "Monthly summary ES-MX"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/monthly-summary-es-mx.html")
}
resource "sparkpost_template" "monthly-summary-pt-br" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Resumo mensal de alertas"
  name                   = "Monthly summary PT-BR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/monthly-summary-pt-br.html")
}

resource "sparkpost_template" "monthly-summary-fr" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Résumé mensuel des alertes"
  name                   = "Monthly summary FR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/monthly-summary-fr.html")
}

resource "sparkpost_template" "monthly-summary-zh" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "每月警报摘要"
  name                   = "Monthly summary ZH"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/monthly-summary-zh.html")
}

resource "sparkpost_template" "monthly-summary-en" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Monthly Summary of Alerts"
  name                   = "Monthly summary EN"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/monthly-summary-en.html")
}

resource "sparkpost_template" "monthly-summary-id" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Ringkasan peringatan bulanan"
  name                   = "Monthly summary ID"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/monthly-summary-id.html")
}

###############################################################################
## These "forest-change-notification-glads-<lang>" email templates seem unused
###############################################################################

resource "sparkpost_template" "forest-change-notification-glads-id" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Peringatan perubahan hutan"
  name                   = "Forest Change Notification (GLAD) ID"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/forest-change-notification-glads-id.html")
}

resource "sparkpost_template" "forest-change-notification-glads-en" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Forest change alert"
  name                   = "Forest Change Notification (GLAD) EN"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/forest-change-notification-glads-en.html")
}

resource "sparkpost_template" "forest-change-notification-glads-es-mx" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Alertas de deforestación "
  name                   = "Forest Change Notification (GLAD) ES-MX"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/forest-change-notification-glads-es-mx.html")
}

resource "sparkpost_template" "forest-change-notification-glads-fr" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Alerte d'évolution forestière"
  name                   = "Forest Change Notification (GLAD) FR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/forest-change-notification-glads-fr.html")
}

resource "sparkpost_template" "forest-change-notification-glads-pt-br" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Alertas de desmatamento"
  name                   = "Forest Change Notification (GLAD) PT-BR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/forest-change-notification-glads-pt-br.html")
}

resource "sparkpost_template" "forest-change-notification-glads-en-updated" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Forest change alert"
  name                   = "Forest Change Notification (GLAD) EN (UPDATED)"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/forest-change-notification-glads-en-updated.html")
}

resource "sparkpost_template" "forest-change-notification-glads-zh" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "森林变化预警"
  name                   = "Forest Change Notification (GLAD) ZH"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/forest-change-notification-glads-zh.html")
}

resource "sparkpost_template" "subscription-confirmation-rw-en" {
  content_from_email     = "no-reply@resourcewatch.org"
  content_from_name      = "Resource Watch"
  content_subject        = "Confirm your Subscription"
  name                   = "Subscription confirmation EN (Resource Watch)"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = false
  published              = true
  content_html           = file("${path.module}/templates/subscription-confirmation-rw-en.html")
  description            = "Confirm your Subscription"
}

resource "sparkpost_template" "subscription-confirmation-pt-br" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Confirme sua inscrição no Global Forest Watch"
  name                   = "Subscription confirmation PT-BR (DO NOT DELETE)"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/subscription-confirmation-pt-br.html")
}

resource "sparkpost_template" "subscription-confirmation-es" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Confirme su suscripción de Global Forest Watch"
  name                   = "Subscription confirmation ES"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/subscription-confirmation-es.html")
}

resource "sparkpost_template" "subscription-confirmation-en" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Confirm your Global Forest Watch subscription"
  name                   = "Subscription confirmation EN"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/subscription-confirmation-en.html")
}

resource "sparkpost_template" "subscription-confirmation-zh" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "请确认您的Global Forest Watch订阅"
  name                   = "Subscription confirmation ZH"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/subscription-confirmation-zh.html")
}

resource "sparkpost_template" "subscription-confirmation-id" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Silakan konfirmasi langganan Global Forest Watch Anda"
  name                   = "Subscription confirmation ID"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/subscription-confirmation-id.html")
}

resource "sparkpost_template" "subscription-confirmation-fr" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Confirmer votre abonnement Global Forest Watch"
  name                   = "Subscription confirmation FR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/subscription-confirmation-fr.html")
}

resource "sparkpost_template" "subscription-confirmation-pt" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Confirme sua inscrição no Global Forest Watch"
  name                   = "Subscription confirmation PT"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/subscription-confirmation-pt.html")
}

resource "sparkpost_template" "subscription-confirmation-es-mx" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Confirme su suscripción de Global Forest Watch"
  name                   = "Subscription confirmation ES-MX (DO NOT DELETE)"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/subscription-confirmation-es-mx.html")
}

#####################################################################
## End of: "forest-change-notification-glads-<lang>" email templates
#####################################################################


###############################################################################
## This "dataset" email seems unused, as all templates have the "dataset-rw-<?env?> structure
###############################################################################

resource "sparkpost_template" "dataset" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_subject        = "Dataset Alerts"
  name                   = "Dataset alert (Resource Watch)"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = false
  published              = true
  content_html           = file("${path.module}/templates/dataset.html")
}

#####################################################################
## End of: "dataset-<?env?>" email templates
#####################################################################

resource "sparkpost_template" "dataset-rw" {
  content_from_email     = "no-reply@resourcewatch.org"
  content_subject        = "{{subject}}"
  name                   = "Dataset alert (Resource Watch)"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = false
  published              = true
  content_html           = file("${path.module}/templates/dataset-rw.html")
}

resource "sparkpost_template" "dataset-rw-staging" {
  content_from_email     = "no-reply@resourcewatch.org"
  content_subject        = "{{subject}}-staging"
  name                   = "Dataset alert (Resource Watch) Staging"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = false
  published              = true
  content_html           = file("${path.module}/templates/dataset-rw-staging.html")
}
