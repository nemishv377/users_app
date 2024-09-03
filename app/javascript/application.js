// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "./cocoon"

if (window.location.hash === '#_=_') {
    window.location.hash = '';  // Remove the hash
    history.pushState('', document.title, window.location.pathname);  // Remove the trailing #
}
