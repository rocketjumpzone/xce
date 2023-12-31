#include "dialog_settings_effects.qh"

#include "slider_picmip.qh"
#include "slider_sbfadetime.qh"
#include "weaponslist.qh"
#include "keybinder.qh"
#include "commandbutton.qh"
#include "textlabel.qh"
#include "checkbox.qh"
#include "textslider.qh"
#include "slider.qh"
#include "radiobutton.qh"
#include "checkbox_slider_invalid.qh"

entity makeXonoticEffectsSettingsTab()
{
	entity me;
	me = NEW(XonoticEffectsSettingsTab);
	me.configureDialog(me);
	return me;
}

float someShadowCvarIsEnabled(entity box)
{
	if(cvar("r_shadow_realtime_dlight"))
		if(cvar("r_shadow_realtime_dlight_shadows"))
			return true;
	if(cvar("r_shadow_realtime_world"))
		if(cvar("r_shadow_realtime_world_shadows"))
			return true;
	return false;
}

void XonoticEffectsSettingsTab_fill(entity me)
{
	entity e, s;
	entity effectsApplyButton = makeXonoticCommandButton(_("Apply immediately"), '0 0 0', "vid_restart", COMMANDBUTTON_APPLY);
	effectsApplyButton.disableOnClick = true;
	float n;
	me.TR(me);

		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Configs:")));
		n = 5 + 2 * boolean(cvar("developer") > 0);
		if(cvar("developer") > 0)
		{
			me.TD(me, 1, 5 / n, e = makeXonoticCommandButton(ZCTX(_("PRE^OMG!")), '1 0 1', "exec effects-omg.cfg", 0));
				e.applyButton = effectsApplyButton;
		}

		me.TD(me, 1, 5 / n, e = makeXonoticCommandButton(ZCTX(_("PRE^Pro")), '0 0 0', "exec xce-pro.cfg", 0));
			e.applyButton = effectsApplyButton;

		me.TD(me, 1, 5 / n, e = makeXonoticCommandButton(ZCTX(_("PRE^Casual")), '0 0 0', "exec xce-casual.cfg", 0));
			e.applyButton = effectsApplyButton;

		me.gotoRC(me, 1.25, 0);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Geometry detail:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider_T("r_subdivisions_tolerance",
			_("Change the smoothness of the curves on the map")));
			e.addValue(e, ZCTX(_("DET^Lowest")), "16");
			e.addValue(e, ZCTX(_("DET^Low")), "8");
			e.addValue(e, ZCTX(_("DET^Normal")), "4");
			e.addValue(e, ZCTX(_("DET^Good")), "3");
			e.addValue(e, ZCTX(_("DET^Best")), "2");
			e.addValue(e, ZCTX(_("DET^Insane")), "1");
			e.configureXonoticTextSliderValues(e);
			e.applyButton = effectsApplyButton;
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Player detail:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("cl_playerdetailreduction"));
			e.addValue(e, ZCTX(_("PDET^Low")), "4");
			e.addValue(e, ZCTX(_("PDET^Medium")), "3");
			e.addValue(e, ZCTX(_("PDET^Normal")), "2");
			e.addValue(e, ZCTX(_("PDET^Good")), "1");
			e.addValue(e, ZCTX(_("PDET^Best")), "0");
			e.configureXonoticTextSliderValues(e);
			e.applyButton = effectsApplyButton;
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Texture resolution:")));
			setDependent(e, "r_showsurfaces", 0, 0);
		me.TD(me, 1, 2, e = makeXonoticPicmipSlider());
			if(cvar("developer") > 0)
				e.addValue(e, ZCTX(_("RES^Leet")), "1337");
			e.addValue(e, ZCTX(_("RES^Lowest")), "3");
			e.addValue(e, ZCTX(_("RES^Very low")), "2");
			e.addValue(e, ZCTX(_("RES^Low")), "1");
			e.addValue(e, ZCTX(_("RES^Normal")), "0");
			e.addValue(e, ZCTX(_("RES^Good")), "-1");
			e.addValue(e, ZCTX(_("RES^Best")), "-2");
			e.configureXonoticTextSliderValues(e);
			setDependent(e, "r_showsurfaces", 0, 0);
			e.applyButton = effectsApplyButton;
	me.TR(me);
		me.TDempty(me, 0.2);
		{
			// detect texture compression method
			float f;
			f = updateCompression();
			switch(f)
			{
				case 0:
					me.TD(me, 1, 2.8, e = makeXonoticCheckBox(1, "r_texture_dds_load", _("Avoid lossy texture compression")));
						e.disabled = 1; // just show the checkbox anyway, but with no ability to control it
						e.applyButton = effectsApplyButton;
					break;
				case 1:
					me.TD(me, 1, 2.8, e = makeXonoticCheckBox(1, "r_texture_dds_load", _("Avoid lossy texture compression")));
						setDependent(e, "r_showsurfaces", 0, 0);
						e.applyButton = effectsApplyButton;
					break;
				case 2:
					me.TD(me, 1, 2.8, e = makeXonoticCheckBox(1, "r_texture_dds_load", _("Avoid lossy texture compression")));
						setDependent(e, "r_showsurfaces", 0, 0);
						makeMulti(e, "gl_texturecompression");
						e.applyButton = effectsApplyButton;
					break;
			}
		}
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1, e = makeXonoticCheckBoxEx_T(1, 0, "r_sky", _("Show sky"), _("Disable sky for performance and visibility")));
		if(cvar("developer") > 0)
		{
			me.TD(me, 1, 1, e = makeXonoticCheckBoxEx_T(3, 0, "r_showsurfaces", _("Show surfaces"),
				_("Disable textures completely for very slow hardware. This gives a huge performance boost, but looks very ugly.")));
		}
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticCheckBox_T(1, "mod_q3bsp_nolightmaps", _("Use lightmaps"),
			_("Use high resolution lightmaps, which will look pretty but use up some extra video memory")));
			e.applyButton = effectsApplyButton;
		me.TD(me, 1, 1, e = makeXonoticCheckBox_T(0, "r_glsl_deluxemapping", _("Deluxe mapping"),
			_("Use per-pixel lighting effects")));
			setDependentAND(e, "vid_gl20", 1, 1, "mod_q3bsp_nolightmaps", 0, 0);
		me.TD(me, 1, 1, e = makeXonoticCheckBox_T(0, "r_shadow_gloss", _("Gloss"),
			_("Enable the use of glossmaps on textures supporting it")));
			setDependentAND3(e, "vid_gl20", 1, 1, "mod_q3bsp_nolightmaps", 0, 0, "r_glsl_deluxemapping", 1, 1);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticCheckBox_T(0, "r_glsl_offsetmapping", _("Offset mapping"),
			_("Offset mapping effect that will make textures with bumpmaps appear like they \"pop out\" of the flat 2D surface")));
			setDependent(e, "vid_gl20", 1, 1);
		me.TD(me, 1, 1, e = makeXonoticCheckBox_T(0, "r_glsl_offsetmapping_reliefmapping", _("Relief mapping"),
			_("Higher quality offset mapping, which also has a huge impact on performance")));
			setDependentAND(e, "vid_gl20", 1, 1, "r_glsl_offsetmapping", 1, 1);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticCheckBox_T(0, "r_water", _("Reflections:"),
			_("Reflection and refraction quality, has a huge impact on performance on maps with reflecting surfaces")));
			setDependent(e, "vid_gl20", 1, 1);
		me.TD(me, 1, 2, e = makeXonoticTextSlider_T("r_water_resolutionmultiplier",
			_("Resolution of reflections/refractions")));
			e.addValue(e, _("Blurred"), "0.25");
			e.addValue(e, ZCTX(_("REFL^Good")), "0.5");
			e.addValue(e, _("Sharp"), "1");
			e.configureXonoticTextSliderValues(e);
			setDependentAND(e, "vid_gl20", 1, 1, "r_water", 1, 1);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticCheckBox_T(0, "cl_decals", _("Decals"),
			_("Enable decals (bullet holes and blood)")));
		me.TD(me, 1, 2, e = makeXonoticCheckBox(0, "cl_decals_models", _("Decals on models")));
			setDependent(e, "cl_decals", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Distance:")));
			setDependent(e, "cl_decals", 1, 1);
		me.TD(me, 1, 2, e = makeXonoticSlider_T(200, 500, 20, "r_drawdecals_drawdistance",
			_("Decals further away than this will not be drawn")));
			setDependent(e, "cl_decals", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Time:")));
			setDependent(e, "cl_decals", 1, 1);
		me.TD(me, 1, 2, e = makeXonoticSlider_T(1, 20, 1, "cl_decals_fadetime",
			_("Time in seconds before decals fade away")));
			setDependent(e, "cl_decals", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Damage effects:")));
		me.TD(me, 1, 2, e = makeXonoticTextSlider("cl_damageeffect"));
			e.addValue(e, ZCTX(_("DMGFX^Disabled")), "0");
			e.addValue(e, _("Skeletal"), "1");
			e.addValue(e, ZCTX(_("DMGFX^All")), "2");
			e.configureXonoticTextSliderValues(e);

	me.gotoRC(me, 0, 3.2); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 3, e = makeXonoticRadioButton_T(1, "r_coronas", "0", _("No dynamic lighting"),
			_("Enable corona flares around certain lights")));
	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticRadioButton_T(1, "gl_flashblend", string_null, _("Fake corona lighting"),
			_("Enable faster but uglier dynamic lights by rendering bright coronas instead of real dynamic lights")));
		makeMulti(e, "r_coronas");
	me.TR(me);
		me.TD(me, 1, 2, e = makeXonoticRadioButton_T(1, "r_shadow_realtime_dlight", string_null, _("Realtime dynamic lighting"),
			_("Enable rendering of dynamic lights such as explosions and rocket lights")));
		makeMulti(e, "r_coronas");
		me.TD(me, 1, 1, e = makeXonoticCheckBox_T(0, "r_shadow_realtime_dlight_shadows", _("Shadows"),
			_("Enable rendering of shadows from dynamic lights")));
			setDependent(e, "r_shadow_realtime_dlight", 1, 1);
	me.TR(me);
		me.TD(me, 1, 2, e = makeXonoticCheckBox_T(0, "r_shadow_realtime_world", _("Realtime world lighting"),
			_("Enable rendering of full realtime world lighting on maps that support it. Note that this might have a big impact on performance.")));
		me.TD(me, 1, 1, e = makeXonoticCheckBox_T(0, "r_shadow_realtime_world_shadows", _("Shadows"),
			_("Enable rendering of shadows from realtime world lights")));
			setDependent(e, "r_shadow_realtime_world", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox_T(0, "r_shadow_usenormalmap", _("Use normal maps"),
			_("Enable use of directional shading on textures")));
			setDependentOR(e, "r_shadow_realtime_dlight", 1, 1, "r_shadow_realtime_world", 1, 1);
		me.TD(me, 1, 1, e = makeXonoticCheckBox(0, "r_shadow_shadowmapping", _("Soft shadows")));
			setDependentWeird(e, someShadowCvarIsEnabled);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox_T(0, "r_coronas_occlusionquery", _("Fade corona according to visibility"),
			_("Fade coronas according to visibility")));
			setDependent(e, "r_coronas", 1, 1);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticCheckBox_T(0, "r_bloom", _("Bloom"),
			_("Enable bloom effect, which brightens the neighboring pixels of very bright pixels. Has a big impact on performance.")));
		me.TD(me, 1, 2, e = makeXonoticCheckBoxEx_T(0.5, 0, "hud_postprocessing_maxbluralpha", _("Extra postprocessing effects"),
			_("Enables special postprocessing effects for when damaged or under water or using a powerup")));
			makeMulti(e, "hud_powerup");
			setDependent(e, "vid_gl20", 1, 1);
	me.TR(me);
		s = makeXonoticSlider_T(0.1, 1, 0.1, "r_motionblur",
			_("Motion blur strength - 0.4 recommended"));
		me.TD(me, 1, 1, e = makeXonoticSliderCheckBox(0, 1, s, _("Motion blur:")));
		if(s.value != e.savedValue)
			e.savedValue = 0.4; // default
		me.TD(me, 1, 2, s);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticCheckBox(0, "cl_particles", _("Particles")));
		me.TD(me, 1, 2, e = makeXonoticCheckBox_T(0, "cl_spawn_point_particles", _("Spawnpoint effects"),
			_("Particles effects at all spawn points and whenever a player spawns")));
			makeMulti(e, "cl_spawn_event_particles");
			setDependent(e, "cl_particles", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Quality:")));
			setDependent(e, "cl_particles", 1, 1);
		me.TD(me, 1, 2, e = makeXonoticSlider_T(0, 3.0, 0.25, "cl_particles_quality",
			_("Multiplier for amount of particles. Less means less particles, which in turn gives for better performance")));
			setDependent(e, "cl_particles", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Distance:")));
			setDependent(e, "cl_particles", 1, 1);
		me.TD(me, 1, 2, e = makeXonoticSlider_T(200, 3000, 200, "r_drawparticles_drawdistance",
			_("Particles further away than this will not be drawn")));
			setDependent(e, "cl_particles", 1, 1);

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, effectsApplyButton);
}
