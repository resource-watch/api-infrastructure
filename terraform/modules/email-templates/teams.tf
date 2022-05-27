#####################
# Sent by: FW Teams
#####################

resource "sparkpost_template" "team-invitation-id" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_subject        = "You have been invited to join a Forest Watcher team"
  name                   = "Team Invitation ID"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/team-invitation-id.html")
}

resource "sparkpost_template" "team-invitation-es" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_subject        = "You have been invited to join a Forest Watcher team"
  name                   = "Team Invitation ES"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/team-invitation-es.html")
}

resource "sparkpost_template" "team-invitation-en" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_subject        = "You have been invited to join a Forest Watcher team"
  name                   = "Team Invitation EN"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/team-invitation-en.html")
}

resource "sparkpost_template" "team-invitation-pt" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_subject        = "You have been invited to join a Forest Watcher team"
  name                   = "Team Invitation PT"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/team-invitation-pt.html")
}

resource "sparkpost_template" "team-invitation-fr" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_subject        = "You have been invited to join a Forest Watcher team"
  name                   = "Team Invitation FR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/team-invitation-fr.html")
}

resource "sparkpost_template" "team-joined-id" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_subject        = "Someone has joined your team"
  name                   = "Team Joined ID"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/team-joined-id.html")
}

resource "sparkpost_template" "team-joined-es" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_subject        = "Someone has joined your team"
  name                   = "Team Joined ES"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/team-joined-es.html")
}

resource "sparkpost_template" "team-joined-en" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_subject        = "Someone has joined your team"
  name                   = "Team Joined EN"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/team-joined-en.html")
}

resource "sparkpost_template" "team-joined-fr" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_subject        = "Someone has joined your team"
  name                   = "Team Joined FR"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/team-joined-fr.html")
}

resource "sparkpost_template" "team-joined-pt" {
  content_from_email     = "no-reply@globalforestwatch.org"
  content_subject        = "Someone has joined your team"
  name                   = "Team Joined PT"
  options_click_tracking = true
  options_open_tracking  = true
  options_transactional  = true
  published              = true
  content_html           = file("${path.module}/templates/team-joined-pt.html")
}

