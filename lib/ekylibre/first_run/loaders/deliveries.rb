# -*- coding: utf-8 -*-
Ekylibre::FirstRun.add_loader :deliveries do |first_run|

  first_run.import_file(:charentes_alliance_incoming_deliveries, "charentes_alliance/appros.csv")

  first_run.import_file(:unicoque_outgoing_deliveries, "unicoque/recolte.csv")

end
