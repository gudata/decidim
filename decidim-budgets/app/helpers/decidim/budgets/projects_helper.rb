# frozen_string_literal: true

module Decidim
  module Budgets
    # A helper to render order and budgets actions
    module ProjectsHelper
      # Render a budget as a currency
      #
      # budget - A integer to represent a budget
      def budget_to_currency(budget)
        number_to_currency budget, unit: Decidim.currency_unit, precision: 0
      end

      # Return a percentage of the current order budget from the total budget
      def current_order_budget_percent
        current_order&.budget_percent.to_f.floor
      end

      # Return a percentage of the current order projects from the total projects
      def current_order_projects_percent
        current_order&.projects_percent.to_f.floor
      end

      # Return the minimum percentage of the current order budget from the total budget
      def current_order_budget_percent_minimum
        return 0 if current_order.minimum_projects_rule?

        component_settings.vote_threshold_percent
      end

      def budget_confirm_disabled_attr
        return if current_order_can_be_checked_out?

        %( disabled="disabled" ).html_safe
      end

      # Return true if the current order is checked out
      delegate :checked_out?, to: :current_order, prefix: true, allow_nil: true

      # Return true if the user can continue to the checkout process
      def current_order_can_be_checked_out?
        current_order&.can_checkout?
      end

      def current_rule_explanation
        return unless current_order

        if current_order.maximum_projects_rule? && current_order.minimum_projects_rule?
          t(".maximum_and_minimum_projects_rule.instruction", maximum_number: current_order.maximum_projects, minimum_number: current_order.minimum_projects)
        elsif current_order.maximum_projects_rule?
          t(".maximum_projects_rule.instruction", maximum_number: current_order.maximum_projects)
        elsif current_order.minimum_projects_rule?
          t(".minimum_projects_rule.instruction", minimum_number: current_order.minimum_projects)
        else
          t(".vote_threshold_percent.instruction", minimum_budget: budget_to_currency(current_order.minimum_budget))
        end
      end

      def current_rule_description
        return unless current_order

        if current_order.maximum_projects_rule? && current_order.minimum_projects_rule?
          t(".maximum_and_minimum_projects_rule.description", maximum_number: current_order.maximum_projects, minimum_number: current_order.minimum_projects)
        elsif current_order.maximum_projects_rule?
          t(".maximum_projects_rule.description", maximum_number: current_order.maximum_projects)
        elsif current_order.minimum_projects_rule?
          t(".minimum_projects_rule.description", minimum_number: current_order.minimum_projects)
        else
          t(".vote_threshold_percent.description", minimum_budget: budget_to_currency(current_order.minimum_budget))
        end
      end

      def maximum_budget_projects_enabled?
        component_settings.vote_rule_group_1_maximum_budget_projects_enabled?
      end

      def minimum_budget_projects_enabled?
        component_settings.vote_rule_group_1_minimum_budget_projects_enabled?
      end

      def vote_threshold_percent
        return component_settings.vote_threshold_percent unless maximum_budget_projects_enabled?
        return 0 unless minimum_budget_projects_enabled?

        ((component_settings.vote_minimum_budget_projects_number.to_f / component_settings.vote_maximum_budget_projects_number.to_f) * 100).floor
      end

      def vote_maximum_budget_projects_number
        current_component.settings.vote_maximum_budget_projects_number
      end
    end
  end
end
