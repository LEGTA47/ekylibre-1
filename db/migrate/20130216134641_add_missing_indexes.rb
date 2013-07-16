class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :account_balances, :account_id
    add_index :affairs, :journal_entry_id
    add_index :asset_depreciations, :financial_year_id
    add_index :assets, :charges_account_id
    add_index :cash_transfers, :emitter_cash_id
    add_index :cash_transfers, :receiver_cash_id
    add_index :cash_transfers, :emitter_journal_entry_id
    add_index :cash_transfers, :receiver_journal_entry_id
    add_index :deposit_items, :deposit_id
    add_index :deposits, :cash_id
    add_index :deposits, :mode_id
    add_index :deposits, :responsible_id
    add_index :deposits, :journal_entry_id
    add_index :documents, :template_id
    # add_index :entities, :nature_id
    add_index :entities, :client_account_id
    add_index :entities, :supplier_account_id
    add_index :entities, :responsible_id
    add_index :entities, :proposer_id
    add_index :entities, :payment_mode_id
    add_index :entities, :sale_price_listing_id
    add_index :entities, :attorney_account_id
    add_index :entity_addresses, :mail_area_id
    add_index :financial_years, :last_journal_entry_id
    add_index :incoming_deliveries, :purchase_id
    add_index :incoming_deliveries, :address_id
    add_index :incoming_deliveries, :mode_id
    add_index :incoming_delivery_items, :delivery_id
    add_index :incoming_delivery_items, :purchase_item_id
    add_index :incoming_delivery_items, :product_id
    # add_index :incoming_delivery_items, :price_id
    # add_index :incoming_delivery_items, :unit_id
    # add_index :incoming_delivery_items, :tracking_id
    add_index :incoming_delivery_items, :move_id
    add_index :incoming_payment_modes, :depositables_account_id
    add_index :incoming_payment_modes, :cash_id
    add_index :incoming_payment_modes, :commission_account_id
    add_index :incoming_payment_modes, :depositables_journal_id
    add_index :incoming_payment_modes, :attorney_journal_id
    add_index :incoming_payments, :mode_id
    add_index :incoming_payments, :payer_id
    add_index :incoming_payments, :deposit_id
    add_index :incoming_payments, :responsible_id
    add_index :incoming_payments, :journal_entry_id
    add_index :incoming_payments, :commission_account_id
    add_index :inventories, :responsible_id
    add_index :inventories, :journal_entry_id
    add_index :inventory_items, :product_id
    add_index :inventory_items, :inventory_id
    add_index :inventory_items, :tracking_id
    # add_index :inventory_items, :unit_id
    add_index :inventory_items, :move_id
    add_index :journal_entries, [:resource_id, :resource_type]
    add_index :journal_entries, :financial_year_id
    add_index :journal_entry_items, :journal_id
    add_index :mandates, :entity_id
    add_index :outgoing_deliveries, :address_id
    add_index :outgoing_deliveries, :mode_id
    add_index :outgoing_deliveries, :transport_id
    add_index :outgoing_deliveries, :transporter_id
    add_index :outgoing_delivery_items, :delivery_id
    add_index :outgoing_delivery_items, :sale_item_id
    add_index :outgoing_delivery_items, :product_id
    # add_index :outgoing_delivery_items, :price_id
    # add_index :outgoing_delivery_items, :unit_id
    # add_index :outgoing_delivery_items, :tracking_id
    add_index :outgoing_delivery_items, :move_id
    add_index :outgoing_payment_modes, :cash_id
    add_index :outgoing_payment_modes, :attorney_journal_id
    add_index :outgoing_payments, :journal_entry_id
    add_index :outgoing_payments, :responsible_id
    add_index :outgoing_payments, :payee_id
    add_index :outgoing_payments, :mode_id
    add_index :outgoing_payments, :cash_id
    add_index :preferences, [:record_value_id, :record_value_type]
    # add_index :product_moves, :unit_id
    add_index :product_price_templates, :tax_id
    add_index :product_price_templates, :supplier_id
    add_index :product_price_templates, :listing_id
    #add_index :product_natures, :unit_id
#     add_index :production_chain_conveyors, :production_chain_id
#     add_index :production_chain_conveyors, :product_nature_id
# #    add_index :production_chain_conveyors, :unit_id
#     add_index :production_chain_conveyors, :source_id
#     add_index :production_chain_conveyors, :target_id
#     add_index :production_chain_work_center_uses, :work_center_id
#     add_index :production_chain_work_centers, :production_chain_id
    add_index :purchase_items, :purchase_id
    add_index :purchase_items, :product_id
 #   add_index :purchase_items, :unit_id
    add_index :purchase_items, :price_id
    add_index :purchase_items, :account_id
    add_index :purchase_items, :tracking_id
    add_index :purchases, :supplier_id
    add_index :purchases, :delivery_address_id
    add_index :purchases, :journal_entry_id
    add_index :purchases, :responsible_id
    add_index :purchases, :nature_id
    add_index :sale_items, :sale_id
    add_index :sale_items, :product_id
    add_index :sale_items, :price_id
    #add_index :sale_items, :unit_id
    add_index :sale_items, :account_id
    add_index :sale_items, :tax_id
    add_index :sale_items, :entity_id
    add_index :sale_items, :tracking_id
    add_index :sale_items, :origin_id
    add_index :sale_natures, :payment_mode_id
    add_index :sale_natures, :journal_id
    add_index :sales, :client_id
    add_index :sales, :nature_id
    add_index :sales, :address_id
    add_index :sales, :invoice_address_id
    add_index :sales, :delivery_address_id
    add_index :sales, :responsible_id
    add_index :sales, :transporter_id
    add_index :sales, :journal_entry_id
    add_index :sales, :origin_id
    add_index :subscriptions, :product_nature_id
    add_index :subscriptions, :address_id
    add_index :subscriptions, :nature_id
    add_index :subscriptions, :subscriber_id
    add_index :subscriptions, :sale_item_id
    add_index :tax_declarations, :financial_year_id
    add_index :tax_declarations, :journal_entry_id
    add_index :trackings, :product_id
    add_index :transfers, :client_id
    add_index :transfers, :journal_entry_id
    add_index :transports, :transporter_id
    add_index :transports, :responsible_id
    add_index :transports, :purchase_id
    add_index :users, :department_id
    add_index :users, :establishment_id
    add_index :users, :profession_id
  end
end