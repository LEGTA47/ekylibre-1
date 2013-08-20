# -*- coding: utf-8 -*-
demo :deliveries do

  Ekylibre::fixturize :coop_incoming_deliveries do |w|

    #############################################################################
    # import Coop Order to make automatic purchase

    price_listing = ProductPriceListing.find_by_code("STD")
    supplier_account = Account.find_or_create_in_chart(:suppliers)
    appro_price_template_tax = Tax.find_by_amount(5.5)

    suppliers = Entity.where(:of_company => false, :supplier => true).reorder(:supplier_account_id, :last_name)
    suppliers ||= LegalEntity.create!(:sale_price_listing_id => price_listing.id, :nature => "company", :language => "fra", :last_name => "All", :supplier_account_id => supplier_account.id, :currency => "eur", :supplier => true)


    # add Coop incoming deliveries

    # status to map
    status = {
      "Liquidé" => :order,
      "A livrer" => :estimate,
      "Supprimé" => :aborted
    }

    pnature = {
      "Maïs classe a" => "seed",
      "Graminées fourragères" => "seed",
      "Légumineuses fourragères" => "seed",
      "Divers" => "seed",
      "Blé tendre" => "seed",
      "Blé dur" => "seed",
      "Orge hiver escourgeon" => "seed",
      "Couverts environnementaux enherbeme" => "seed",

      "Engrais" => "chemical_fertilizer",

      "Fongicides céréales" => "fungicide",
      "Fongicides colza" => "fungicide",
      "Herbicides maïs" => "herbicide",
      "Herbicides totaux" => "herbicide",
      "Adjuvants" => "herbicide",
      "Herbicides autres" => "herbicide",
      "Herbicides céréales et fouragères" => "herbicide",

      "Céréales"  => "feed",
      "Chevaux" => "feed",
      "Compléments nutritionnels" => "feed",
      "Minéraux sel blocs" => "feed",

      "Anti-limaces" => "insecticide",

      "Location semoir" => "spread_renting",

      "Nettoyants" => "mineral_cleaner",

      "Films plastiques" => "small_equipment",
      "Recyclage" => "small_equipment",
      "Ficelles" => "small_equipment"
    }

    file = Rails.root.join("test", "fixtures", "files", "coop_appro.csv")
    CSV.foreach(file, :encoding => "UTF-8", :col_sep => ";", :headers => true) do |row|
      r = OpenStruct.new(:order_number => row[0],
                         :ordered_on => Date.civil(*row[1].to_s.split(/\//).reverse.map(&:to_i)),
                         :product_nature_name => (pnature[row[3]] || "small_equipment"),
                         :matter_name => row[4],
                         :quantity => (row[5].blank? ? nil : row[5].to_d),
                         :product_deliver_quantity => (row[6].blank? ? nil : row[6].to_d),
                         :product_unit_price => (row[7].blank? ? nil : row[7].to_d),
                         :order_status => (status[row[8]] || :draft)
                         )
      # create an incoming deliveries if not exist and status = 2
      if r.order_status == :order
        order = IncomingDelivery.find_by_reference_number(r.order_number)
        order ||= IncomingDelivery.create!(:reference_number => r.order_number, :received_at => r.ordered_on, :sender_id => Entity.of_company.id, :address_id => Entity.of_company.default_mail_address.id)
        # find a product_nature by mapping current sub_family of coop file
        product_nature = ProductNature.find_by_nomen(r.product_nature_name)
        product_nature ||= ProductNature.import_from_nomenclature(r.product_nature_name)
        # find a product_nature_variant by mapping current article of coop file
        product_nature_variant = ProductNatureVariant.find_by_name_and_nature_id(r.matter_name,product_nature.id )
        product_nature_variant ||= product_nature.variants.create!(:name => r.matter_name, :active => true, :unit_name => "unit")
        # find a price from current supplier for a consider variant
        product_nature_variant_price = ProductPrice.find_by_supplier_id_and_variant_id_and_pretax_amount(Entity.of_company.id, product_nature_variant.id, r.product_unit_price)
        product_nature_variant_price ||= ProductPrice.create!(:pretax_amount => r.product_unit_price,
                                                              :currency => "EUR",
                                                              :supplier_id => Entity.of_company.id,
                                                              :tax_id => appro_price_template_tax.id,
                                                              :amount => appro_price_template_tax.amount_of(r.product_unit_price),
                                                              :variant_id => product_nature_variant.id
                                                              )

        product_model = product_nature.matching_model
        incoming_item = Product.find_by_variant_id_and_created_at(product_nature_variant.id, r.ordered_on)
        incoming_item ||= product_model.create!(:owner_id => Entity.of_company.id, :identification_number => r.order_number, :variant_id => product_nature_variant.id, :born_at => r.ordered_on, :created_at => r.ordered_on)

        incoming_item.is_measured!(:population, r.quantity.in_unity, :at => Time.now)
        if product_nature.present? and incoming_item.present?
          order.items.create!(:product_id => incoming_item.id, :quantity => r.product_deliver_quantity)
        end
      end

      w.check_point
    end

  end

  Ekylibre::fixturize :coop_outgoing_deliveries do |w|
    # #############################################################################
    # # import Coop Deliveries to make automatic sales
    # # @TODO finish with two level (sales and sales_lines)
    # @TODO make some correction for act_as_numbered
    # # set the coop
    # print "[#{(Time.now - start).round(2).to_s.rjust(8)}s] OutgoingDelivery - Charentes Alliance Coop Delivery (Apport) 2013: "
    # clients = Entity.where(:of_company => false).reorder(:client_account_id, :last_name) # .where(" IS NOT NULL")
    # coop = clients.offset((clients.count/2).floor).first
    # unit_u = Unit.get(:u)
    # # add a Coop sale_nature
    # sale_nature   = SaleNature.actives.first
    # sale_nature ||= SaleNature.create!(:name => I18n.t('models.sale_nature.default.name'), :currency => "EUR", :active => true)
    # # Asset Code
    # sale_account_nature_coop = Account.find_by_number("701")
    # stock_account_nature_coop = Account.find_by_number("321")

    # file = Rails.root.join("test", "fixtures", "files", "coop-apport.csv")
    # CSV.foreach(file, :encoding => "UTF-8", :col_sep => ";", :headers => false, :quote_char => "'") do |row|
    #   r = OpenStruct.new(:delivery_number => row[0],
    #                      :delivered_on => Date.civil(*row[1].to_s.split(/\//).reverse.map(&:to_i)),
    #                      :delivery_place => row[2],
    #                      :product_nature_name => row[3],
    #                      :product_net_weight => row[4].to_d,
    #                      :product_standard_weight => row[5].to_d,
    #                      :product_humidity => row[6].to_d,
    #                      :product_impurity => row[7].to_d,
    #                      :product_specific_weight => row[8].to_d,
    #                      :product_proteins => row[9].to_d,
    #                      :product_cal => row[10].to_d,
    #                      :product_mad => row[11].to_d,
    #                      :product_grade => row[12].to_d,
    #                      :product_expansion => row[13].to_d
    #                      )
    #   # create a purchase if not exist
    #   sale   = Sale.find_by_reference_number(r.delivery_number)
    #   sale ||= Sale.create!(:state => r.order_status, :currency => "EUR", :nature_id => purchase_nature.id, :reference_number => r.order_number, :supplier_id => coop.id, :planned_on => r.ordered_on, :created_on => r.ordered_on)
    #   tax_price_nature_appro = Tax.find_by_amount(19.6)
    #   # create a product_nature if not exist
    #   product_nature   = ProductNature.find_by_name(r.product_nature_name)
    #   product_nature ||= ProductNature.create!(:stock_account_id => stock_account_nature_coop.id, :charge_account_id => charge_account_nature_coop.id, :name => r.product_nature_name, :number => r.product_nature_name,  :saleable => false, :purchasable => true, :active => true, :storable => true, :variety_id => b.id, :unit_id => unit_u.id, :category_id => ProductNatureCategory.by_default.id)
    #   # create a product (Matter) if not exist
    #   product   = Matter.find_by_name(r.matter_name)
    #   product ||= Matter.create!(:name => r.matter_name, :identification_number => r.matter_name, :work_number => r.matter_name, :born_at => Time.now, :nature_id => product_nature.id, :owner_id => Entity.of_company.id, :number => r.matter_name) #
    #   # create a product_price_template if not exist
    #   product_price   = ProductPriceTemplate.find_by_product_nature_id_and_supplier_id_and_assignment_pretax_amount(product_nature.id, coop.id, r.product_unit_price)
    #   product_price ||= ProductPriceTemplate.create!(:currency => "EUR", :assignment_pretax_amount => r.product_unit_price, :product_nature_id => product_nature.id, :tax_id => tax_price_nature_appro.id, :supplier_id => coop.id)
    #   # create a purchase_item if not exist
    #   # purchase_item   = PurchaseItem.find_by_product_id_and_purchase_id_and_price_id(product.id, purchase.id, product_price.id)
    #   # purchase_item ||= PurchaseItem.create!(:quantity => r.quantity, :unit_id => unit_u.id, :price_id => product_price.id, :product_id => product.id, :purchase_id => purchase.id)
    #   purchase.items.create!(:quantity => r.quantity, :product_id => product.id)
    #   # create an incoming_delivery if status => 2

    #   # create an incoming_delivery_item if status => 2


    #   print "."
    # end
    # puts "!"
    ##############################################################################
    ## Demo data for document                                                   ##
    ##############################################################################

    # import an outgoing_deliveries_journal in PDF"
    document = Document.create!(:key => "20130724_outgoing_001", :name => "outgoing_001", :nature => "outgoing_delivery_journal" )
    File.open(Rails.root.join("test", "fixtures", "files", "releve_apports.pdf"),"rb") do |f|
      document.archive(f.read, :pdf)
    end

  end

end