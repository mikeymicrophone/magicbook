import "@hotwired/turbo-rails"
import "controllers"

// Existing pages still use Turbolinks and jquery-ujs. Turbo Frames and Streams
// are enabled for the publishing editor, while Drive stays off during the
// incremental migration.
Turbo.session.drive = false
