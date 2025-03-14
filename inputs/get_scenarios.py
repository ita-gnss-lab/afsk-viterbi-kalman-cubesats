from datetime import datetime, timezone, timedelta

from skyfield.api import wgs84

import scintpy

def get_scenarios():
    # UTC time 2024-10-28 07:00:00+00:00
    reference_time = datetime(2024, 10, 28, 7, 0, 0, tzinfo=timezone.utc)
    # São José dos Campos
    receiver_pos = wgs84.latlon(-23.20713241666, -45.861737777, 605.088)
    
    scenarios = []
    scenarios_ = []
    while len(scenarios) < 10:
        for sat, rise_time, set_time in scintpy.geom.find_LOS_sats(
            reference_time, receiver_pos, is_online=False, satellite_system="cubesat"
        ):
            # if the satellite is already in the list, continue the for loop and search
            # for the next in line-of-sight satellite
            if sat.name in [scenario.satellite.name for scenario in scenarios_]:
                continue
            scenario = scintpy.geom.get_scenario(sat, receiver_pos, rise_time, set_time)
            # save scenario suitable to Matlab
            scenarios.append(
                {
                    "sat_name": scenario.satellite.name,
                    "sat_orbit": {
                        "altitude_deg": scenario.alt_deg,
                        "azimuth_rad": scenario.az_rad
                    },
                    "receiver": {
                        "latitude_deg": scenario.receiver.latitude.degrees,
                        "longitude_deg": scenario.receiver.longitude.degrees,
                        "elevation_km": scenario.receiver.elevation.km
                    },
                    "range_km": scenario.rel_dist_km,
                    "time_sec": [datetime_.total_seconds() for datetime_ in scenario.time.utc_datetime() - scenario.time[0].utc_datetime()],
                    "rise_time_utc": scenario.time[0].utc_datetime(),
                    "set_time_utc": scenario.time[-1].utc_datetime(),
                }
            )
            scenarios_.append(scenario)
            # get only 10 satellites
            if len(scenarios) == 10:
                break
        # for the given reference time, there are too few LOS satellites
        # search if again for another reference time
        reference_time += timedelta(minutes=30)
      
    # NOTE: uncomment it to plot the satellite orbits
    #scintpy.geom.plot_sat_orbits(scenarios_)
    return scenarios

get_scenarios()