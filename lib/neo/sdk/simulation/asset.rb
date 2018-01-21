# frozen_string_literal: true

module Neo
  module SDK
    class Simulation
      # A class meant for mocking and stubbing in your tests
      class Asset
        class << self
          #  Register a new asset
          def create(asset_type, name, amount, precision, owner, admin, issuer); end

          # Obtain the administrator (contract address) of the asset
          def get_admin; end

          # Get the total amount of the asset
          def get_amount; end

          # Get ID of the asset
          def get_asset_id; end

          # Get the category of the asset
          def get_asset_type; end

          # Get the quantity of the asset that has been issued
          def get_available; end

          # Obtain the issuer (contract address) of the asset
          def get_issuer; end

          # Get the owner of the asset (public key)
          def get_owner; end

          # Get the number of divisions for this asset, the number of digits after the decimal point
          def get_precision; end

          #  Renew an asset
          def renew(years); end
        end
      end
    end
  end
end
