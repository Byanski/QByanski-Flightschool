# QByanski-Flightschool

A **FiveM Flight School resource** for QBCore/QBox servers. This fork adds full plane and helicopter flight tests, license awarding, ox_fuel compatibility, and proper integration with QBox's inventory and license systems.

---

## Features

- **Plane and Helicopter Flight Tests**
  - Automatic vehicle spawn at designated flight test locations.
  - Player is automatically warped into the aircraft.
  - Flight theory and practical tests fully functional.

- **License Awarding**
  - Removes the temporary flight school permit on test completion.
  - Grants the appropriate license item (`aviationlicense1` for planes, `aviationlicense2` for helicopters).
  - Registers the license in the QBox/QBCore system so it can be recognized in city hall and purchase menus.

- **Ox_Fuel Compatibility**
  - Sets aircraft fuel to full using `SetVehicleFuelLevel`, compatible with ox_fuel.
  - No dependency on legacy fuel systems.

- **Debug Information**
  - Prints test type and vehicle model to console during spawn for troubleshooting.
  - Warns in console if an invalid test type is detected.

- **Server-Side Inventory Handling**
  - All inventory changes (permit removal, license awarding) are handled **server-side** to ensure compatibility with modern QBox/QBCore.

---

## Installation

1. Place the resource in your FiveM `resources` folder, e.g.:

   ```
   resources/[qb]/qbyanski-flightschool
   ```

2. Add the resource to your `server.cfg`:

   ```cfg
   ensure qbyanski-flightschool
   ```

3. Ensure your `Config.VehicleModels` contains valid plane and helicopter models. Example:

   ```lua
   Config.VehicleModels = {
       ["aviationlicense1"] = "velum",  -- Plane test
       ["aviationlicense2"] = "maverick" -- Helicopter test
   }
   ```

4. Make sure your `shared/items.lua` includes the license items and flight permit:

   ```lua
   ["aviationlicense1"] = {"name"="aviationlicense1","label"="Aviation License 1","weight"=100,"type"="item","image"="aviationlicense1.png","unique"=true,"useable"=false,"shouldClose"=true,"combinable"=nil,"description"="License for fixed-wing aircraft"},
   ["aviationlicense2"] = {"name"="aviationlicense2","label"="Aviation License 2","weight"=100,"type"="item","image"="aviationlicense2.png","unique"=true,"useable"=false,"shouldClose"=true,"combinable"=nil,"description"="License for helicopters"},
   ["flightschool_permit"] = {"name"="flightschool_permit","label"="Flight School Permit","weight"=10,"type"="item","image"="permit.png","unique"=true,"useable"=false,"shouldClose"=true,"combinable"=nil,"description"="Permit to take flight tests"},
   ```

---

## Usage

1. **Start a flight test** via the flight school menu:

   ```lua
   StartFlightTest("aviationlicense1") -- Plane
   StartFlightTest("aviationlicense2") -- Helicopter
   ```

   - This spawns the aircraft at the configured location and warps the player in automatically.

2. **Complete the test**:

   - Upon passing, the client triggers:

     ```lua
     TriggerServerEvent('qb-flightschool:server:CompleteTest', CurrentTestType)
     ```

   - This removes the flight school permit and gives the player the correct license item.
   - The license is also registered in the QBox/QBCore system for purchase/ID verification.

3. **Failing the test** simply triggers a notification; no inventory changes occur.

---

## Server-Side Event: Complete Test

`server/main.lua` contains:

```lua
RegisterNetEvent('qb-flightschool:server:CompleteTest', function(testType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Remove the old permit
    Player.Functions.RemoveItem("flightschool_permit", 1)

    -- Give license based on test type
    if testType == "aviationlicense1" then
        Player.Functions.AddItem("aviationlicense1", 1)
    elseif testType == "aviationlicense2" then
        Player.Functions.AddItem("aviationlicense2", 1)
    else
        print("WARNING: Unknown test type:", testType)
    end

    -- Register license in QBox/QCore
    TriggerEvent('qb-flightschool:server:AddLicense', testType, src)
end)
```

---

## Notes / Changes Made

- Converted legacy inventory calls to server-side event handling.
- Replaced legacy fuel (`LegacyFuel`) with `SetVehicleFuelLevel` for ox_fuel.
- Added debug console logs for easier troubleshooting.
- License awarding now uses explicit checks to match test type → inventory item.
- Flight theory test now correctly grants the license item upon completion.

---

## Dependencies

- [QBCore](https://github.com/qbcore-framework/qb-core) or [QBox](https://github.com/qbcore-framework/qbox)
- ox_fuel
- vehiclekeys (for warping player into vehicle and key assignment)

---

## License

MIT License — feel free to use and modify for your server.