namespace :blokade do
  namespace :permissions do

    # Backend Tasks
    namespace :backend do
      desc "Creates or updates the default permissions for the entire system"
      task set_default: :environment do
        Blokade.permission_class.backend_permissions.each do |model, nested_hash|
          puts "Current model: #{model}..."
          nested_hash.each do |permission_key, sub_hash|
            puts "Current backend permission: #{permission_key}"
            Blokade.permission_class.find_or_create_by(action: sub_hash[:action], subject_class: sub_hash[:subject_class], description: sub_hash[:description], backend: true)
          end
        end
        puts "...done!"
      end

      desc "Nukes all backend permissions in the system"
      task nuke: :environment do
        puts "Nuking all backend permissions..."
        Blokade.permission_class.backend.destroy_all
        puts "...done!"
      end
    end

    # Frontend Tasks
    namespace :frontend do
      desc "Creates or updates the default permissions for the entire system"
      task set_default: :environment do
        Blokade.permission_class.frontend_permissions.each do |model, nested_hash|
          puts "Current model: #{model}..."
          nested_hash.each do |permission_key, sub_hash|
            puts "Current frontend permission: #{permission_key}"
            if sub_hash[:enable_restrictions]
              Blokade.permission_class.find_or_create_by(action: sub_hash[:action], subject_class: sub_hash[:subject_class], description: sub_hash[:description], backend: false, enable_restrictions: true)
            end
            Blokade.permission_class.find_or_create_by(action: sub_hash[:action], subject_class: sub_hash[:subject_class], description: sub_hash[:description], backend: false, enable_restrictions: false)
          end
        end

        puts "creating symbolic permissions..."
        Blokade.symbolic_frontend_blokades.each
        Blokade.symbolic_frontend_blokades.each do |hash|
          hash.each do |k, v|
            Blokade.permission_class.find_or_create_by(action: ":#{k}", subject_class: ":#{v}", description: "#{k} #{v}", backend: false)
          end
        end
        puts "...done!"
      end

      desc "Fixes all administrator roles to have all appropriate frontend permissions"
      task fix_admin: :environment do
        Blokade.role_class.where(key: 'administrator').find_each do |role|
          puts "Fixing frontend administator role ..."
          role.permission_ids = Blokade.permission_class.all.frontend.unrestricted.pluck(:id)
        end
        puts "...done!"
      end

      desc "Nukes all frontend permissions in the system"
      task nuke: :environment do
        puts "Nuking all frontend permissions..."
        Blokade.permission_class.frontend.destroy_all
        puts "...done!"
      end
    end

  end
end