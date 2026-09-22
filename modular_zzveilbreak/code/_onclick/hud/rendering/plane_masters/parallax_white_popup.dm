/*
 * VEILBREAK MODULAR OVERRIDE
 *
 * Replaces /atom/movable/screen/plane_master/parallax_white inside popup
 * plane master groups only (camera consoles, spyglasses, etc).
 *
 * Upstream behavior: parallax_updated() applies a full-white color matrix
 * whenever the viewing HUD has TRAIT_PARALLAX_DISPLAYED. Popups inherit
 * that trait from the mob's main HUD, but they never receive the parallax
 * layers themselves - those live on client.parallax_rock and render on the
 * main window's plane group. With nothing to multiply against it, the white
 * backdrop shows through and every space turf inside the popup renders
 * solid white.
 *
 * Popups therefore keep the plane master (so its emissive relay to
 * RENDER_PLANE_EMISSIVE at EMISSIVE_SPACE_LAYER stays intact) but leave it
 * transparent. The main window's parallax_white is untouched.
 *
 * Reproduction on stock /tg/station: set parallax to High or above, open a
 * camera console, point a camera at space. Affects every downstream.
 */

/atom/movable/screen/plane_master/parallax_white/veilbreak_popup

/atom/movable/screen/plane_master/parallax_white/veilbreak_popup/parallax_updated(datum/source)
	SIGNAL_HANDLER
	if(isnull(home.our_hud?.mymob))
		return
	color = initial(color)
