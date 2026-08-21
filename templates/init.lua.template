local capabilities = require "st.capabilities"
local ZigbeeDriver = require "st.zigbee"
local defaults = require "st.zigbee.defaults"
local clusters = require "st.zigbee.zcl.clusters"
local device_management = require "st.zigbee.device_management"
local constants = require "st.zigbee.constants"

local IASZone = clusters.IASZone
local PowerConfiguration = clusters.PowerConfiguration
local DRIVER_INFO_CAPABILITY_ID = "buildbook37604.driverInformation"
local driver_info = capabilities[DRIVER_INFO_CAPABILITY_ID]

local MOTION_TIMER = "motionResetTimer"
local TIMER_GENERATION = "motionTimerGeneration"
local LAST_ACCEPTED_MOTION = "lastAcceptedMotionMonotonic"

local DEFAULT_DETECTION_INTERVAL = 0.1
local DEFAULT_INACTIVE_INTERVAL = 15

local function preference_number(device, name, default_value, minimum, maximum)
  local value = tonumber(device.preferences and device.preferences[name]) or default_value
  if value < minimum then value = minimum end
  if value > maximum then value = maximum end
  return value
end

local function detection_interval(device)
  return preference_number(device, "detectionInterval", DEFAULT_DETECTION_INTERVAL, 0.1, 3600)
end

local function inactive_interval(device)
  return preference_number(device, "inactiveInterval", DEFAULT_INACTIVE_INTERVAL, 0.1, 3600)
end

local function extend_on_motion(device)
  local value = device.preferences and device.preferences.extendOnMotion
  if value == nil then return true end
  return value == true
end

local function cancel_motion_timer(device)
  local timer = device:get_field(MOTION_TIMER)
  if timer ~= nil then
    pcall(function() device.thread:cancel_timer(timer) end)
    device:set_field(MOTION_TIMER, nil)
  end
end

local function next_timer_generation(device)
  local generation = (device:get_field(TIMER_GENERATION) or 0) + 1
  device:set_field(TIMER_GENERATION, generation)
  return generation
end

local function schedule_motion_inactive(device, restart)
  if restart then
    cancel_motion_timer(device)
  elseif device:get_field(MOTION_TIMER) ~= nil then
    return
  end

  local generation = next_timer_generation(device)
  local timer = device.thread:call_with_delay(inactive_interval(device), function()
    if device:get_field(TIMER_GENERATION) ~= generation then return end
    device:emit_event(capabilities.motionSensor.motion.inactive())
    device:set_field(MOTION_TIMER, nil)
  end)
  device:set_field(MOTION_TIMER, timer)
end

local function accept_motion_report(device)
  local now = os.clock()
  local last = device:get_field(LAST_ACCEPTED_MOTION)
  if last ~= nil and (now - last) < detection_interval(device) then
    return false
  end
  device:set_field(LAST_ACCEPTED_MOTION, now)
  return true
end

local function process_motion_active(device)
  if not accept_motion_report(device) then return end

  local current = device:get_latest_state(
    "main",
    capabilities.motionSensor.ID,
    capabilities.motionSensor.motion.NAME
  )

  if current ~= "active" then
    device:emit_event(capabilities.motionSensor.motion.active())
    schedule_motion_inactive(device, true)
    return
  end

  if extend_on_motion(device) then
    schedule_motion_inactive(device, true)
  end
end

local function emit_motion_from_zone_status(device, zone_status)
  if zone_status:is_alarm1_set() then
    process_motion_active(device)
  end
end

local function ias_zone_status_attr_handler(driver, device, zone_status, zb_rx)
  emit_motion_from_zone_status(device, zone_status)
end

local function ias_zone_status_change_handler(driver, device, zb_rx)
  emit_motion_from_zone_status(device, zb_rx.body.zcl_body.zone_status)
end

local function emit_driver_information(device)
  if driver_info then
    if driver_info.author then
      device:emit_event(driver_info.author("치즈가루"))
    end
    if driver_info.driverVersion then
      device:emit_event(driver_info.driverVersion("v1.0.4"))
    end
  end
end

local function device_added(driver, device)
  device:emit_event(capabilities.motionSensor.motion.inactive())
  emit_driver_information(device)
end

local function device_init(driver, device)
  emit_driver_information(device)
end

local function do_configure(driver, device)
  device:configure()
  device:send(device_management.build_bind_request(device, IASZone.ID, driver.environment_info.hub_zigbee_eui))
  device:send(IASZone.attributes.ZoneStatus:configure_reporting(device, 1, 300, 1))
  device:send(device_management.build_bind_request(device, PowerConfiguration.ID, driver.environment_info.hub_zigbee_eui))
  device:send(PowerConfiguration.attributes.BatteryPercentageRemaining:configure_reporting(device, 30, 21600, 1))
  device:send(PowerConfiguration.attributes.BatteryPercentageRemaining:read(device))
end

local function info_changed(driver, device, event, args)
  local old_preferences = (args.old_st_store and args.old_st_store.preferences) or {}
  local current_preferences = device.preferences or {}

  local inactive_changed = old_preferences.inactiveInterval ~= current_preferences.inactiveInterval
  local extend_changed = old_preferences.extendOnMotion ~= current_preferences.extendOnMotion

  if inactive_changed or extend_changed then
    local current_motion = device:get_latest_state(
      "main",
      capabilities.motionSensor.ID,
      capabilities.motionSensor.motion.NAME
    )
    if current_motion == "active" then
      schedule_motion_inactive(device, true)
    end
  end

  emit_driver_information(device)
end

local function refresh_handler(driver, device, command)
  device:send(IASZone.attributes.ZoneStatus:read(device))
  device:send(PowerConfiguration.attributes.BatteryPercentageRemaining:read(device))
  emit_driver_information(device)
end

local driver_template = {
  supported_capabilities = {
    capabilities.motionSensor,
    capabilities.battery,
    capabilities.refresh,
    driver_info
  },
  zigbee_handlers = {
    attr = {
      [IASZone.ID] = {
        [IASZone.attributes.ZoneStatus.ID] = ias_zone_status_attr_handler
      }
    },
    cluster = {
      [IASZone.ID] = {
        [IASZone.client.commands.ZoneStatusChangeNotification.ID] = ias_zone_status_change_handler
      }
    }
  },
  capability_handlers = {
    [capabilities.refresh.ID] = {
      [capabilities.refresh.commands.refresh.NAME] = refresh_handler
    }
  },
  lifecycle_handlers = {
    added = device_added,
    init = device_init,
    doConfigure = do_configure,
    infoChanged = info_changed
  },
  ias_zone_configuration_method = constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
  health_check = false
}

local filtered_capabilities = {}
for _, capability in ipairs(driver_template.supported_capabilities) do
  if capability ~= nil then table.insert(filtered_capabilities, capability) end
end
driver_template.supported_capabilities = filtered_capabilities

defaults.register_for_default_handlers(driver_template, driver_template.supported_capabilities)
ZigbeeDriver("C.P MotionSensor", driver_template):run()
