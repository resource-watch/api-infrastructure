locals {
  templates = [
    sparkpost_template.dashboard-complete-en, sparkpost_template.dashboard-pending-fr,
    sparkpost_template.glad-updated-notification-id, sparkpost_template.dashboard-complete-id,
    sparkpost_template.team-invitation-id, sparkpost_template.contact-form-confirmation-fr,
    sparkpost_template.subscription-preference-change-zh, sparkpost_template.forest-change-notification-glads-id,
    sparkpost_template.forest-change-notification-glads-en, sparkpost_template.forest-fires-notification-viirs-fr,
    sparkpost_template.monthly-summary-es-mx, sparkpost_template.subscription-confirmation-pt,
    sparkpost_template.team-joined-es, sparkpost_template.dashboard-pending-zh,
    sparkpost_template.subscription-confirmation-es-mx, sparkpost_template.contact-form-confirmation-pt,
    sparkpost_template.glad-updated-notification-en, sparkpost_template.monthly-summary-pt-br,
    sparkpost_template.dataset, sparkpost_template.dashboard-complete-es_MX, sparkpost_template.team-joined-id,
    sparkpost_template.subscription-confirmation-fr, sparkpost_template.team-joined-en, sparkpost_template.rw-dataset,
    sparkpost_template.contact-form, sparkpost_template.contact-form-confirmation-zh,
    sparkpost_template.team-invitation-es, sparkpost_template.forest-fires-notification-viirs-en-updated,
    sparkpost_template.dashboard-pending-pt_BR, sparkpost_template.monthly-summary-fr,
    sparkpost_template.subscription-confirmation-zh, sparkpost_template.subscription-confirmation-id,
    sparkpost_template.forest-change-notification-glads-es-mx, sparkpost_template.monthly-summary-zh,
    sparkpost_template.contact-form-confirmation-es, sparkpost_template.glad-updated-notification-pt-br,
    sparkpost_template.subscription-preference-change-en, sparkpost_template.monthly-summary-en,
    sparkpost_template.monthly-summary-id, sparkpost_template.forest-fires-notification-viirs-es-mx,
    sparkpost_template.forest-fires-notification-viirs-id, sparkpost_template.subscription-confirmation-en,
    sparkpost_template.recover-password, sparkpost_template.forest-change-notification-glads-fr,
    sparkpost_template.glad-updated-notification-zh, sparkpost_template.team-joined-fr, sparkpost_template.confirm-user,
    sparkpost_template.glad-updated-notification-fr, sparkpost_template.subscription-confirmation-rw-en,
    sparkpost_template.subscription-preference-change-es_MX, sparkpost_template.dashboard-pending-en,
    sparkpost_template.confirm-user-with-password, sparkpost_template.glad-updated-notification-es-mx,
    sparkpost_template.subscription-confirmation-pt-br, sparkpost_template.dataset-rw-staging,
    sparkpost_template.forest-change-notification-glads-pt-br, sparkpost_template.subscription-preference-change-pt_BR,
    sparkpost_template.contact-form-confirmation-id, sparkpost_template.dashboard-complete-fr,
    sparkpost_template.subscription-confirmation-es, sparkpost_template.dataset-rw, sparkpost_template.team-joined-pt,
    sparkpost_template.forest-change-notification-glads-en-updated, sparkpost_template.team-invitation-en,
    sparkpost_template.forest-fires-notification-viirs-pt-br, sparkpost_template.forest-fires-notification-viirs-en,
    sparkpost_template.forest-change-notification-glads-zh, sparkpost_template.subscription-preference-change-id,
    sparkpost_template.contact-form-confirmation-en, sparkpost_template.forest-fires-notification-viirs-zh,
    sparkpost_template.dashboard-complete-zh, sparkpost_template.subscription-preference-change-fr,
    sparkpost_template.dashboard-pending-es_MX, sparkpost_template.dashboard-complete-pt_BR,
    sparkpost_template.dashboard-pending-id, sparkpost_template.team-invitation-pt,
    sparkpost_template.team-invitation-fr,
  ]
}

output "template-map" {
  value = [for template in local.templates : {
    template_name = template.name
    template_id   = template.id
  }]
}

output "template-ids" {
  value = [for template in local.templates : template.id]
}
