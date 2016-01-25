module Payola
  class Engine < ::Rails::Engine
    isolate_namespace Payola
    engine_name 'payola'

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end

    initializer :inject_helpers do |app|
      ActiveSupport.on_load :action_controller do
        ::ActionController::Base.send(:helper, Payola::PriceHelper)
      end

      ActiveSupport.on_load :action_mailer do
        ::ActionMailer::Base.send(:helper, Payola::PriceHelper)
      end
    end

    initializer :configure_subscription_listeners do |app|
      Payola.configure do |config|
        config.subscribe 'invoice.payment_succeeded',     Payola::InvoicePaid
        config.subscribe 'invoice.payment_failed',        Payola::InvoiceFailed
        config.subscribe 'customer.subscription.updated', Payola::SyncSubscription
        config.subscribe 'customer.subscription.deleted', Payola::SubscriptionDeleted
      end
    end
  end
end
