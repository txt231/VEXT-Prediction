# VEXT-Prediction

Some simple bullet, grenade and rocket prediction for vu

Is accurate enough in most cases

## Might be helpful to do
- sometimes it does not like some nil value, even tho i check it????
- detect fire action, and store prediction data
- prediction for other players (performance)

NOTE: Might be more notes i forgot or missed
## Notes:
- this does not account for spread, so if your weapon/grenade has spread it might not be as accurate
- this might be expensive for some computers, right now its updating with 30 ticks.
- this does not account for pitch initialspeed diffrence (might not even be in this game?)
- some ghetto raycast fix cause i cant add ignored entities, check **vu improvements** below
- grenade bounces can go through ground in some cases...

## VU Improvements needed for more accuracy:

- real shootspace. preferably with spread info, but normal shootspace works fine. (check "fb::ClientWeapon::getProjectileInfo")
- materialmanager needed for bullet penetration stuff, and can also do accurate damage prediction
- raycast might not need checkdetailmesh **(not sure)**
- raycast doesnt have ignored entities


## Screenshot

![Grenade example image](https://i.imgur.com/BunMqAn.png)
