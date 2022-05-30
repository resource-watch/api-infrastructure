#####################
# Sent by: Area MS
#####################

resource "sparkpost_template" "dashboard-complete-en" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Dashboard complete for {{ name }}"
  name                   = "Dashboard complete EN"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/dashboard-complete-en.html")
}

resource "sparkpost_template" "dashboard-pending-fr" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Votre tableau de bord est en attente"
  name                   = "Dashboard pending FR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/dashboard-pending-fr.html")
}

resource "sparkpost_template" "dashboard-complete-id" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Dasbor lengkap untuk kawasan yang baru Anda buat {{ name }}"
  name                   = "Dashboard complete ID"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/dashboard-complete-id.html")
}

resource "sparkpost_template" "dashboard-pending-zh" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "信息面板整理中"
  name                   = "Dashboard pending ZH"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/dashboard-pending-zh.html")
}

resource "sparkpost_template" "dashboard-complete-es_MX" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "El tablero del área creada recientemente está completo {{ name }}"
  name                   = "Dashboard complete ES-MX"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/dashboard-complete-es_MX.html")
}

resource "sparkpost_template" "dashboard-pending-pt_BR" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Painel sendo criado"
  name                   = "Dashboard pending PT-BR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/dashboard-pending-pt_BR.html")
}

resource "sparkpost_template" "dashboard-pending-en" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Dashboard pending for {{ name }}"
  name                   = "Dashboard pending EN"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/dashboard-pending-en.html")
}

resource "sparkpost_template" "dashboard-complete-fr" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Tableau de bord terminé pour la zone que vous avez récemment créée {{ name }}"
  name                   = "Dashboard complete FR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/dashboard-complete-fr.html")
}

resource "sparkpost_template" "dashboard-complete-zh" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "您最近创建的区域已完成信息面板 {{ name }}"
  name                   = "Dashboard complete ZH"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/dashboard-complete-zh.html")
}

resource "sparkpost_template" "dashboard-pending-es_MX" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Actualización de panel en proceso"
  name                   = "Dashboard pending ES-MX"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/dashboard-pending-es_MX.html")
}

resource "sparkpost_template" "dashboard-complete-pt_BR" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Painel concluído para a área recém-criada {{ name }}"
  name                   = "Dashboard complete PT-BR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/dashboard-complete-pt_BR.html")
}

resource "sparkpost_template" "dashboard-pending-id" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Dasbor tertunda"
  name                   = "Dashboard pending ID"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/dashboard-pending-id.html")
}

resource "sparkpost_template" "subscription-preference-change-zh" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "您的区域订阅偏好已更改 {{ name }}"
  name                   = "Subscription preferences changed ZH"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/subscription-preference-change-zh.html")
}
resource "sparkpost_template" "subscription-preference-change-en" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Subscription preferences changed for {{ name }}"
  name                   = "Subscription preferences changed EN"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/subscription-preference-change-en.html")
}
resource "sparkpost_template" "subscription-preference-change-es_MX" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Se modificaron las preferencias de suscripción para su área {{ name }}"
  name                   = "Subscription preferences changed ES-MX"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/subscription-preference-change-es_MX.html")
}
resource "sparkpost_template" "subscription-preference-change-pt_BR" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Preferências de assinatura alteradas para sua área {{ name }}"
  name                   = "Subscription preferences changed PT-BR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/subscription-preference-change-pt_BR.html")
}
resource "sparkpost_template" "subscription-preference-change-id" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Preferensi berlangganan berubah untuk kawasan Anda {{ name }}"
  name                   = "Subscription preferences changed ID"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/subscription-preference-change-id.html")
}
resource "sparkpost_template" "subscription-preference-change-fr" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_from_name      = "Global Forest Watch"
  content_subject        = "Préférences d’abonnement modifiées pour votre zone {{ name }}"
  name                   = "Subscription preferences changed FR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/subscription-preference-change-fr.html")
}
