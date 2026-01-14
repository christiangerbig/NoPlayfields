; Requirements
; 68020+
; AGA PAL
; 3.0+


; History/Changes

; V.1.0 beta
; - 1st release

; V.1.1 beta
; - revised include files included

; V1.2 beta
; - prod renamed to "NoPlayfields"

; V1.3 beta
; - Grass' logo added

; V.1.4 beta
; - Grass' font added
; - Font colour changed
; - Ma2e's module added
; - Grettings updated

; V.1.5 beta
; - Module bugfix: Due to the fact that I added an extra pattern at position 0
;   the module didn't restart correctly anymore. Fx command B01 changed to B02.

; V.1.6 beta
; - Grass' updated font included
; - fader enabled

; V.1.0
; - bootable adf created
; - workbench start activated


; PT 8xy command
; 810	Start Blind-Fader-In
; 820	Start Vert-Scrolltext


; Execution time 68020: 207 rasterlines


	MC68040


	INCDIR "include3.5:"

	INCLUDE "exec/exec.i"
	INCLUDE "exec/exec_lib.i"

	INCLUDE "dos/dos.i"
	INCLUDE "dos/dos_lib.i"
	INCLUDE "dos/dosextens.i"

	INCLUDE "graphics/gfxbase.i"
	INCLUDE "graphics/graphics_lib.i"
	INCLUDE "graphics/videocontrol.i"

	INCLUDE "intuition/intuition.i"
	INCLUDE "intuition/intuition_lib.i"

	INCLUDE "libraries/any_lib.i"

	INCLUDE "resources/cia_lib.i"

	INCLUDE "hardware/adkbits.i"
	INCLUDE "hardware/blit.i"
	INCLUDE "hardware/cia.i"
	INCLUDE "hardware/custom.i"
	INCLUDE "hardware/dmabits.i"
	INCLUDE "hardware/intbits.i"


	INCDIR "custom-includes-aga:"


PROTRACKER_VERSION_3		SET 1


	INCLUDE "macros.i"


	INCLUDE "equals.i"

requires_030_cpu		EQU FALSE
requires_040_cpu		EQU FALSE
requires_060_cpu		EQU FALSE
requires_fast_memory		EQU FALSE
requires_multiscan_monitor	EQU FALSE

workbench_start_enabled		EQU TRUE
screen_fader_enabled		EQU TRUE
text_output_enabled		EQU FALSE

open_border_enabled		EQU TRUE

pt_ciatiming_enabled		EQU TRUE
pt_usedfx			EQU %1111110101011110
pt_usedefx			EQU %0000000001000000
pt_mute_enabled			EQU FALSE
pt_music_fader_enabled		EQU TRUE
pt_fade_out_delay		EQU 1	; tick
pt_split_module_enabled		EQU TRUE
pt_track_notes_played_enabled	EQU TRUE
pt_track_volumes_enabled	EQU TRUE
pt_track_periods_enabled	EQU TRUE
pt_track_data_enabled		EQU FALSE
	IFD PROTRACKER_VERSION_3
pt_metronome_enabled		EQU FALSE
pt_metrochanbits		EQU pt_metrochan1
pt_metrospeedbits		EQU pt_metrospeed4th
	ENDC

; Vert-Colorscroll 3.1.1.1
vcs3111_bplam_table_length_256	EQU TRUE

	IFEQ open_border_enabled
dma_bits			EQU DMAF_SPRITE|DMAF_BLITTER|DMAF_COPPER|DMAF_MASTER|DMAF_SETCLR
	ELSE
dma_bits			EQU DMAF_SPRITE|DMAF_BLITTER|DMAF_COPPER|DMAF_RASTER|DMAF_MASTER|DMAF_SETCLR
	ENDC

	IFEQ pt_ciatiming_enabled
intena_bits			EQU INTF_EXTER|INTF_INTEN|INTF_SETCLR
	ELSE
intena_bits			EQU INTF_VERTB|INTF_EXTER|INTF_INTEN|INTF_SETCLR
	ENDC

ciaa_icr_bits			EQU CIAICRF_SETCLR
	IFEQ pt_ciatiming_enabled
ciab_icr_bits			EQU CIAICRF_TA|CIAICRF_TB|CIAICRF_SETCLR
	ELSE
ciab_icr_bits			EQU CIAICRF_TB|CIAICRF_SETCLR
	ENDC

copcon_bits			EQU 0

pf1_x_size1			EQU 0
pf1_y_size1			EQU 0
pf1_depth1			EQU 0
pf1_x_size2			EQU 0
pf1_y_size2			EQU 0
pf1_depth2			EQU 0
	IFEQ open_border_enabled
pf1_x_size3			EQU 0
pf1_y_size3			EQU 0
pf1_depth3			EQU 0
	ELSE
pf1_x_size3			EQU 32
pf1_y_size3			EQU 1
pf1_depth3			EQU 1
	ENDC
pf1_colors_number		EQU 0	; 256

pf2_x_size1			EQU 0
pf2_y_size1			EQU 0
pf2_depth1			EQU 0
pf2_x_size2			EQU 0
pf2_y_size2			EQU 0
pf2_depth2			EQU 0
pf2_x_size3			EQU 0
pf2_y_size3			EQU 0
pf2_depth3			EQU 0
pf2_colors_number		EQU 0
pf_colors_number		EQU pf1_colors_number+pf2_colors_number
pf_depth			EQU pf1_depth3+pf2_depth3

pf_extra_number			EQU 0

spr_number			EQU 8
spr_x_size1			EQU 32
spr_x_size2			EQU 32
spr_depth			EQU 2
spr_colors_number		EQU 0	; 4
spr_odd_color_table_select	EQU 13	; logo
spr_even_color_table_select	EQU 10	; scroll text
spr_used_number			EQU 1
spr_swap_number			EQU 1

	IFD PROTRACKER_VERSION_2 
audio_memory_size		EQU 0
	ENDC
	IFD PROTRACKER_VERSION_3
audio_memory_size		EQU 1*WORD_SIZE
	ENDC

disk_memory_size		EQU 0

chip_memory_size		EQU 0

	IFEQ pt_ciatiming_enabled
ciab_cra_bits			EQU CIACRBF_LOAD
	ENDC
ciab_crb_bits			EQU CIACRBF_LOAD|CIACRBF_RUNMODE ; oneshot mode
ciaa_ta_time			EQU 0
ciaa_tb_time			EQU 0
	IFEQ pt_ciatiming_enabled
ciab_ta_time			EQU 14187 ;= 0.709379 MHz * [20000 탎 = 50 Hz duration for one frame on a PAL machine]
;ciab_ta_time			EQU 14318 ;= 0.715909 MHz * [20000 탎 = 50 Hz duration for one frame on a NTSC machine]
	ELSE
ciab_ta_time			EQU 0
	ENDC
ciab_tb_time			EQU 362 ;= 0.709379 MHz * [511.43 탎 = Lowest note period C1 with Tuning=-8 * 2 / PAL clock constant = 907*2/3546895 ticks per second]
					;= 0.715909 MHz * [506.76 탎 = Lowest note period C1 with Tuning=-8 * 2 / NTSC clock constant = 907*2/3579545 ticks per second]
ciaa_ta_continuous_enabled	EQU FALSE
ciaa_tb_continuous_enabled	EQU FALSE
	IFEQ pt_ciatiming_enabled
ciab_ta_continuous_enabled	EQU TRUE
	ELSE
ciab_ta_continuous_enabled	EQU FALSE
	ENDC
ciab_tb_continuous_enabled	EQU FALSE

beam_position			EQU $133

pixel_per_line			EQU 32
visible_pixels_number		EQU 352
visible_lines_number		EQU 256
MINROW				EQU VSTART_256_LINES

pf_pixel_per_datafetch		EQU 16	; 1x
spr_pixel_per_datafetch		EQU 32	; 2x

display_window_hstart		EQU HSTART_44_CHUNKY_PIXEL
display_window_vstart		EQU MINROW
display_window_hstop		EQU HSTOP_44_CHUNKY_PIXEL
display_window_vstop		EQU VSTOP_256_LINES

pf1_plane_width			EQU pf1_x_size3/8
data_fetch_width		EQU pixel_per_line/8
pf1_plane_moduli		EQU -(pf1_plane_width-(pf1_plane_width-data_fetch_width))

	IFEQ open_border_enabled
diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|BPLCON0F_COLOR|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon3_bits1			EQU BPLCON3F_SPRES0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)|(BPLCON4F_ESPRM4*spr_even_color_table_select)
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)
fmode_bits			EQU FMODEF_SPR32
	ELSE
diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
ddfstrt_bits			EQU DDFSTRT_OVERSCAN_32_PIXEL
ddfstop_bits			EQU DDFSTOP_OVERSCAN_32_PIXEL_MIN
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|BPLCON0F_COLOR?((pf_depth&$07)*BPLCON0F_BPU0)
bplcon3_bits1			EQU BPLCON3F_SPRES0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)|(BPLCON4F_ESPRM4*spr_even_color_table_select)
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)
fmode_bits			EQU FMODEF_SPR32
	ENDC
color00_bits			EQU $001122

cl2_display_x_size		EQU 352
cl2_display_width		EQU cl2_display_x_size/8
cl2_display_y_size		EQU visible_lines_number
	IFEQ open_border_enabled
cl2_hstart1			EQU display_window_hstart-(1*CMOVE_SLOT_PERIOD)-4
	ELSE
cl2_hstart1			EQU display_window_hstart-4
	ENDC
cl2_vstart1			EQU MINROW
cl2_hstart2			EQU 0
cl2_vstart2			EQU beam_position&CL_Y_WRAPPING

sine_table_length		EQU 256

; Logo
lg_image_x_size			EQU 32
lg_image_plane_width		EQU lg_image_x_size/8
lg_image_y_size			EQU 256
lg_image_depth			EQU 16

lg_image_x_position		EQU display_window_hstart
lg_image_y_position		EQU display_window_vstart

; Volume-Meter
vm_source_chan1			EQU 0
vm_source_chan2			EQU 1
vm_source_chan3			EQU 2
vm_period_div			EQU 15
vm_max_period_step		EQU 6
vm_volume_div			EQU 8

; Vert-Colorscroll 3.1.1.1
vcs3111_bar_height		EQU 128
vcs3111_bars_number		EQU 2
vcs3111_step1			EQU 1
vcs3111_step2_min		EQU 5
vcs3111_step2_max		EQU 13
vcs3111_step2			EQU vcs3111_step2_max-vcs3111_step2_min
vcs3111_step2_radius		EQU vcs3111_step2
vcs3111_step2_center		EQU vcs3111_step2+vcs3111_step2_min

; Vert-Scrolltext
vst_used_sprites_number		EQU 1

vst_image_x_size		EQU 320
vst_image_plane_width		EQU vst_image_x_size/8
vst_image_depth			EQU 1

vst_origin_char_x_size		EQU 16
vst_origin_char_y_size		EQU 15
vst_origin_charcter_depth	EQU vst_image_depth

vst_text_char_x_size		EQU 16
vst_text_char_width		EQU vst_text_char_x_size/8
vst_text_char_y_size		EQU vst_origin_char_y_size+1
vst_text_char_depth		EQU vst_image_depth

vst_vert_scroll_window_x_size	EQU vst_text_char_x_size
vst_vert_scroll_window_width	EQU vst_vert_scroll_window_x_size/8
vst_vert_scroll_window_y_size	EQU visible_lines_number+vst_text_char_y_size
vst_vert_scroll_window_depth	EQU vst_image_depth
vst_vert_scroll_speed		EQU 1

vst_text_char_y_shift_max	EQU vst_text_char_y_size
vst_text_char_y_restart		EQU vst_vert_scroll_window_y_size
vst_text_chars_number		EQU vst_vert_scroll_window_y_size/vst_text_char_y_size

vst_object_x_size		EQU 32
vst_object_width		EQU vst_object_x_size/8
vst_object_y_size		EQU visible_lines_number+(vst_text_char_y_size*2)
vst_object_depth		EQU 2

vst_copy_blit_x_size		EQU vst_text_char_x_size
vst_copy_blit_y_size		EQU vst_text_char_y_size*vst_text_char_depth

; Blind-Fader
bf_lamella_height		EQU 16
bf_lamellas_number		EQU cl2_display_y_size/bf_lamella_height
bf_step1			EQU 1
bf_step2			EQU 1
bf_speed			EQU 2

bf_registers_table_length	EQU bf_lamella_height*4


color_step1			EQU 256/(vcs3111_bar_height/2)
color_values_number1		EQU vcs3111_bar_height/2
segments_number1		EQU vcs3111_bars_number*2

ct_size1			EQU color_values_number1*segments_number1

vcs3111_bplam_table_size	EQU ct_size1

extra_memory_size		EQU vcs3111_bplam_table_size*BYTE_SIZE


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


; PT-Replay
	INCLUDE "music-tracker/pt-song.i"

	INCLUDE "music-tracker/pt-temp-channel.i"


	RSRESET

audio_channel_info		RS.B 0

aci_speed			RS.W 1
aci_step2_anglespeed		RS.W 1
aci_step2_anglestep		RS.W 1

audio_channel_info_size		RS.B 0


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1.i"

cl1_COPJMP2			RS.L 1

copperlist1_size		RS.B 0


	RSRESET

cl2_extension1			RS.B 0

cl2_ext1_WAIT			RS.L 1
	IFEQ open_border_enabled 
cl2_ext1_BPL1DAT		RS.L 1
	ENDC
cl2_ext1_BPLCON4_1		RS.L 1
cl2_ext1_BPLCON4_2		RS.L 1
cl2_ext1_BPLCON4_3		RS.L 1
cl2_ext1_BPLCON4_4		RS.L 1
cl2_ext1_BPLCON4_5		RS.L 1
cl2_ext1_BPLCON4_6		RS.L 1
cl2_ext1_BPLCON4_7		RS.L 1
cl2_ext1_BPLCON4_8		RS.L 1
cl2_ext1_BPLCON4_9		RS.L 1
cl2_ext1_BPLCON4_10		RS.L 1
cl2_ext1_BPLCON4_11		RS.L 1
cl2_ext1_BPLCON4_12		RS.L 1
cl2_ext1_BPLCON4_13		RS.L 1
cl2_ext1_BPLCON4_14		RS.L 1
cl2_ext1_BPLCON4_15		RS.L 1
cl2_ext1_BPLCON4_16		RS.L 1
cl2_ext1_BPLCON4_17		RS.L 1
cl2_ext1_BPLCON4_18		RS.L 1
cl2_ext1_BPLCON4_19		RS.L 1
cl2_ext1_BPLCON4_20		RS.L 1
cl2_ext1_BPLCON4_21		RS.L 1
cl2_ext1_BPLCON4_22		RS.L 1
cl2_ext1_BPLCON4_23		RS.L 1
cl2_ext1_BPLCON4_24		RS.L 1
cl2_ext1_BPLCON4_25		RS.L 1
cl2_ext1_BPLCON4_26		RS.L 1
cl2_ext1_BPLCON4_27		RS.L 1
cl2_ext1_BPLCON4_28		RS.L 1
cl2_ext1_BPLCON4_29		RS.L 1
cl2_ext1_BPLCON4_30		RS.L 1
cl2_ext1_BPLCON4_31		RS.L 1
cl2_ext1_BPLCON4_32		RS.L 1
cl2_ext1_BPLCON4_33		RS.L 1
cl2_ext1_BPLCON4_34		RS.L 1
cl2_ext1_BPLCON4_35		RS.L 1
cl2_ext1_BPLCON4_36		RS.L 1
cl2_ext1_BPLCON4_37		RS.L 1
cl2_ext1_BPLCON4_38		RS.L 1
cl2_ext1_BPLCON4_39		RS.L 1
cl2_ext1_BPLCON4_40		RS.L 1
cl2_ext1_BPLCON4_41		RS.L 1
cl2_ext1_BPLCON4_42		RS.L 1
cl2_ext1_BPLCON4_43		RS.L 1
cl2_ext1_BPLCON4_44		RS.L 1

cl2_extension1_size		RS.B 0


	RSRESET

cl2_begin			RS.B 0

cl2_extension1_entry		RS.B cl2_extension1_size*cl2_display_y_size

cl2_WAIT			RS.L 1
cl2_INTREQ			RS.L 1

cl2_end				RS.L 1

copperlist2_size		RS.B 0


cl1_size1			EQU 0
cl1_size2			EQU 0
cl1_size3			EQU copperlist1_size

cl2_size1			EQU 0
cl2_size2			EQU copperlist2_size
cl2_size3			EQU copperlist2_size


; Sprite0 additional structure
	RSRESET

spr0_extension1	RS.B 0

spr0_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr0_ext1_planedata		RS.L lg_image_y_size*(spr_pixel_per_datafetch/WORD_BITS)

spr0_extension1_size		RS.B 0


; Sprite0 main structure
	RSRESET

spr0_begin			RS.B 0

spr0_extension1_entry RS.B spr0_extension1_size

spr0_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite0_size			RS.B 0

; Sprite1 additional structure
	RSRESET

spr1_extension1			RS.B 0

spr1_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr1_ext1_planedata		RS.L lg_image_y_size*(spr_pixel_per_datafetch/WORD_BITS)

spr1_extension1_size		RS.B 0

; Sprite1 main structure
	RSRESET

spr1_begin			RS.B 0

spr1_extension1_entry		RS.B spr1_extension1_size

spr1_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite1_size			RS.B 0

; Sprite2 additional structure
	RSRESET

spr2_extension1	RS.B 0

spr2_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr2_ext1_planedata		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)*vst_object_y_size

spr2_extension1_size		RS.B 0

; Sprite2 main structure
	RSRESET

spr2_begin			RS.B 0

spr2_extension1_entry		RS.B spr2_extension1_size

spr2_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite2_size			RS.B 0

; Sprite3 main structure
	RSRESET

spr3_begin			RS.B 0

spr3_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite3_size			RS.B 0

; Sprite4 main structure
	RSRESET

spr4_begin			RS.B 0

spr4_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite4_size	RS.B 0

; Sprite5 main structure
	RSRESET

spr5_begin			RS.B 0

spr5_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite5_size			RS.B 0

; Sprite6 main structure
	RSRESET

spr6_begin			RS.B 0

spr6_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite6_size			RS.B 0

; Sprite7 main structure
	RSRESET

spr7_begin			RS.B 0

spr7_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite7_size			RS.B 0


spr0_x_size1			EQU spr_x_size1
spr0_y_size1			EQU sprite0_size/(spr_x_size1/4)
spr1_x_size1			EQU spr_x_size1
spr1_y_size1			EQU sprite1_size/(spr_x_size1/4)
spr2_x_size1			EQU spr_x_size1
spr2_y_size1			EQU sprite2_size/(spr_x_size1/4)
spr3_x_size1			EQU spr_x_size1
spr3_y_size1			EQU sprite3_size/(spr_x_size1/4)
spr4_x_size1			EQU spr_x_size1
spr4_y_size1			EQU sprite4_size/(spr_x_size1/4)
spr5_x_size1			EQU spr_x_size1
spr5_y_size1			EQU sprite5_size/(spr_x_size1/4)
spr6_x_size1			EQU spr_x_size1
spr6_y_size1			EQU sprite6_size/(spr_x_size1/4)
spr7_x_size1			EQU spr_x_size1
spr7_y_size1			EQU sprite7_size/(spr_x_size1/4)

spr0_x_size2			EQU spr_x_size2
spr0_y_size2			EQU sprite0_size/(spr_x_size2/4)
spr1_x_size2			EQU spr_x_size2
spr1_y_size2			EQU sprite1_size/(spr_x_size2/4)
spr2_x_size2			EQU spr_x_size2
spr2_y_size2			EQU sprite2_size/(spr_x_size2/4)
spr3_x_size2			EQU spr_x_size2
spr3_y_size2			EQU sprite3_size/(spr_x_size2/4)
spr4_x_size2			EQU spr_x_size2
spr4_y_size2			EQU sprite4_size/(spr_x_size2/4)
spr5_x_size2			EQU spr_x_size2
spr5_y_size2			EQU sprite5_size/(spr_x_size2/4)
spr6_x_size2			EQU spr_x_size2
spr6_y_size2			EQU sprite6_size/(spr_x_size2/4)
spr7_x_size2			EQU spr_x_size2
spr7_y_size2			EQU sprite7_size/(spr_x_size2/4)


	RSRESET

	INCLUDE "main-variables.i"

save_a7				RS.L 1

; PT-Replay
	IFD PROTRACKER_VERSION_2 
		INCLUDE "music-tracker/pt2-variables.i"
	ENDC
	IFD PROTRACKER_VERSION_3
		INCLUDE "music-tracker/pt3-variables.i"
	ENDC

pt_effects_handler_active	RS.W 1

; Vert-Colorscroll 3.1.1.1
vcs3111_bplam_table_start	RS.W 1
vcs3111_step2_angle		RS.W 1

; Vert-Scrolltext
vst_active			RS.W 1
	RS_ALIGN_LONGWORD
vst_image			RS.L 1
vst_text_table_start		RS.W 1

; Blind-Fader
	IFEQ open_border_enabled
bf_registers_table_start	RS.W 1

; Blind-Fader-In
bfi_active			RS.W 1

; Blind-Fader-Out
bfo_active			RS.W 1
	ENDC

; Main
stop_fx_active			RS.W 1

variables_size			RS.B 0


	SECTION code,CODE


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; PT-Replay
	IFD PROTRACKER_VERSION_2 
		PT2_INIT_VARIABLES
	ENDC
	IFD PROTRACKER_VERSION_3
		PT3_INIT_VARIABLES
	ENDC

	moveq	#TRUE,d0
	move.w	d0,pt_effects_handler_active(a3)

; Vert-Colorscroll 3.1.1.1
	move.w	d0,vcs3111_bplam_table_start(a3)
	move.w	#sine_table_length/4,vcs3111_step2_angle(a3)

; Vert-Scrolltext
	moveq	#FALSE,d1
	move.w	d1,vst_active(a3)
	lea	vst_image_data,a0
	move.l	a0,vst_image(a3)
	move.w	d0,vst_text_table_start(a3)

; Blind-Fader
	IFEQ open_border_enabled
		move.w	d0,bf_registers_table_start(a3)

; Blind-Fader-In
		move.w	d1,bfi_active(a3)

; Blind-Fader-Out
		move.w	d1,bfo_active(a3)
	ENDC

; Main
	move.w	d1,stop_fx_active(a3)
	rts


	CNOP 0,4
init_main
	bsr.s	pt_DetectSysFrequ
	bsr.s	pt_InitRegisters
	bsr	pt_InitAudTempStrucs
	bsr	pt_ExamineSongStruc
	bsr	pt_InitFtuPeriodTableStarts
	bsr	vm_init_audio_channels_info
	bsr	vcs3111_init_bplam_table
	bsr	vst_init_chars_offsets
	bsr	vst_init_chars_y_positions
	bsr	vst_init_chars_images
	bsr	init_colors
	bsr	init_sprites
	bsr	init_CIA_timers
	bsr	init_first_copperlist
	bra	init_second_copperlist


; PT-Replay
	PT_DETECT_SYS_FREQUENCY

	PT_INIT_REGISTERS

	PT_INIT_AUDIO_TEMP_STRUCTURES

	PT_EXAMINE_SONG_STRUCTURE

	PT_INIT_FINETUNE_TABLE_STARTS


; Volume-Meter
	CNOP 0,4
vm_init_audio_channels_info
	lea	vm_audio_channel1_info(pc),a0
	moveq	#0,d0
	move.w  d0,aci_speed(a0)
	move.w  d0,aci_step2_anglespeed(a0)
	move.w  d0,aci_step2_anglestep(a0)
	lea	vm_audio_channel2_info(pc),a0
	move.w  d0,aci_speed(a0)
	move.w  d0,aci_step2_anglespeed(a0)
	move.w  d0,aci_step2_anglestep(a0)
	lea	vm_audio_channel3_info(pc),a0
	move.w  d0,aci_speed(a0)
	move.w  d0,aci_step2_anglespeed(a0)
	move.w  d0,aci_step2_anglestep(a0)
	lea	vm_audio_channel4_info(pc),a0
	move.w  d0,aci_speed(a0)
	move.w  d0,aci_step2_anglespeed(a0)
	move.w  d0,aci_step2_anglestep(a0)
	rts


; Vert-Colorscroll
	INIT_BPLAM_TABLE.B vcs3111,0,1,color_values_number1*segments_number1,extra_memory,a3


; Vert-Scrolltext
	INIT_CHARS_OFFSETS.W vst

	INIT_CHARS_Y_POSITIONS vst

	INIT_CHARS_IMAGES vst


	CNOP 0,4
init_colors
	CPU_SELECT_COLOR_HIGH_BANK 0
	CPU_INIT_COLOR_HIGH COLOR00,32,pf1_rgb8_color_table
	CPU_SELECT_COLOR_HIGH_BANK 1
	CPU_INIT_COLOR_HIGH COLOR00,32
	CPU_SELECT_COLOR_HIGH_BANK 2
	CPU_INIT_COLOR_HIGH COLOR00,32
	CPU_SELECT_COLOR_HIGH_BANK 3
	CPU_INIT_COLOR_HIGH COLOR00,32
	CPU_SELECT_COLOR_HIGH_BANK 4
	CPU_INIT_COLOR_HIGH COLOR00,32
	CPU_SELECT_COLOR_HIGH_BANK 5
	CPU_INIT_COLOR_HIGH COLOR00,32
	CPU_SELECT_COLOR_HIGH_BANK 6
	CPU_INIT_COLOR_HIGH COLOR00,32
	CPU_SELECT_COLOR_HIGH_BANK 7
	CPU_INIT_COLOR_HIGH COLOR00,32

	CPU_SELECT_COLOR_LOW_BANK 0
	CPU_INIT_COLOR_LOW COLOR00,32,pf1_rgb8_color_table
	CPU_SELECT_COLOR_LOW_BANK 1
	CPU_INIT_COLOR_LOW COLOR00,32
	CPU_SELECT_COLOR_LOW_BANK 2
	CPU_INIT_COLOR_LOW COLOR00,32
	CPU_SELECT_COLOR_LOW_BANK 3
	CPU_INIT_COLOR_LOW COLOR00,32
	CPU_SELECT_COLOR_LOW_BANK 4
	CPU_INIT_COLOR_LOW COLOR00,32
	CPU_SELECT_COLOR_LOW_BANK 5
	CPU_INIT_COLOR_LOW COLOR00,32
	CPU_SELECT_COLOR_LOW_BANK 6
	CPU_INIT_COLOR_LOW COLOR00,32
	CPU_SELECT_COLOR_LOW_BANK 7
	CPU_INIT_COLOR_LOW COLOR00,32
	rts


	CNOP 0,4
init_sprites
	bsr.s	spr_init_pointers_table
	bsr.s	lg_init_sprites
	bsr	vst_init_xy_coordinates
	bra	spr_copy_structures

	INIT_SPRITE_POINTERS_TABLE


; Logo
	CNOP 0,4
lg_init_sprites
	move.w	#lg_image_x_position*SHIRES_PIXEL_FACTOR,d0 ; HSTART
	moveq	#lg_image_y_position,d1	; VSTART
	move.w	#lg_image_y_size,d2
	add.w	d1,d2			; VSTOP
	lea	spr_pointers_construction(pc),a2
	SET_SPRITE_POSITION d0,d1,d2
	move.l	(a2)+,a0		; 1st sprite structure
	move.w	d1,(a0)			; SPRPOS
	move.w	d2,spr_pixel_per_datafetch/8(a0) ; SPRCTL
	ADDF.W	(spr_pixel_per_datafetch/4),a0 ; skip sprite header
	move.l	(a2),a1			; 2nd sprite structure
	move.w	d1,(a1)			; SPRPOS
	or.b	#SPRCTLF_ATT,d2
	move.w	d2,spr_pixel_per_datafetch/8(a1) ; SPRCTL
	ADDF.W	(spr_pixel_per_datafetch/4),a1 ; skip sprite header
	lea	lg_image_data,a2
	MOVEF.W lg_image_y_size-1,d7
lg_init_sprites_loop
	move.l	(a2)+,(a0)+		; bitplane 1
	move.l	(a2)+,(a0)+		; bitplane 2
	move.l	(a2)+,(a1)+		; bitplane 3
	move.l	(a2)+,(a1)+		; bitplane 4
	dbf	d7,lg_init_sprites_loop
	rts


; Vert-Scrolltext
	CNOP 0,4
vst_init_xy_coordinates
	move.w	#(display_window_hstop-vst_text_char_x_size)*SHIRES_PIXEL_FACTOR,d0 ; HSTART
	moveq	#display_window_vstart-vst_text_char_y_size,d1 ; VSTART
	move.w	#vst_object_y_size,d2
	add.w	d1,d2			; VSTOP
	move.l	spr_pointers_construction+(2*LONGWORD_SIZE)(pc),a0 ; sprite2 structure
	SET_SPRITE_POSITION d0,d1,d2
	move.w	d1,(a0)			; SPRPOS
	move.w	d2,spr_pixel_per_datafetch/8(a0) ; SPRCTL
	rts

	COPY_SPRITE_STRUCTURES


	CNOP 0,4
init_CIA_timers

; PT-Replay
	PT_INIT_TIMERS
	rts


	CNOP 0,4
init_first_copperlist
	move.l	cl1_display(a3),a0
	bsr.s	cl1_init_playfield_props
	bsr.s	cl1_init_sprite_pointers
	IFEQ open_border_enabled
		COP_MOVEQ 0,COPJMP2
		bra	cl1_set_sprite_pointers
	ELSE
		bsr.s	cl1_init_bitplane_pointers
		COP_MOVEQ 0,COPJMP2
		bsr	cl1_set_sprite_pointers
		bra	cl1_set_bitplane_pointers
	ENDC

	IFEQ open_border_enabled
		COP_INIT_PLAYFIELD_REGISTERS cl1,NOBITPLANESSPR
	ELSE
		COP_INIT_PLAYFIELD_REGISTERS cl1
		COP_INIT_BITPLANE_POINTERS cl1
		COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3
	ENDC


	COP_INIT_SPRITE_POINTERS cl1


	COP_SET_SPRITE_POINTERS cl1,display,spr_number


	CNOP 0,4
init_second_copperlist
	move.l	cl2_construction2(a3),a0 
	bsr.s	cl2_init_bplcon4_chunky
	bsr.s	cl2_init_copper_interrupt
	COP_LISTEND
	bsr	copy_second_copperlist
	bsr	swap_second_copperlist
	bra	set_second_copperlist


	COP_INIT_BPLCON4_CHUNKY cl2,cl2_hstart1,cl2_vstart1,cl2_display_x_size,cl2_display_y_size,open_border_enabled,FALSE,FALSE,NOOP<<16


	COP_INIT_COPINT cl2,cl2_hstart2,cl2_vstart2


	COPY_COPPERLIST cl2,2


	CNOP 0,4
main
	bsr.s	no_sync_routines
	bra.s	beam_routines


	CNOP 0,4
no_sync_routines
	rts


	CNOP 0,4
beam_routines
	bsr	wait_copint
	bsr.s	swap_second_copperlist
	bsr.s	set_second_copperlist
	bsr.s	swap_sprite_structures
	bsr.s	set_sprite_pointers
	bsr	vert_scrolltext
	bsr	get_channels_amplitudes
	bsr	vert_colorscroll3111
	IFEQ open_border_enabled
		bsr	blind_fader_in
		bsr	blind_fader_out
	ENDC
	bsr	mouse_handler
	tst.w	stop_fx_active(a3)
	bne	beam_routines
	rts


	SWAP_COPPERLIST cl2,2


	SET_COPPERLIST cl2


	SWAP_SPRITES spr_swap_number,2


	SET_SPRITES spr_swap_number,2


	CNOP 0,4
get_channels_amplitudes
	moveq	#vm_period_div,d2
	moveq	#vm_volume_div,d3
	lea	pt_audchan1temp(pc),a0
	lea	vm_audio_channel1_info(pc),a1
	bsr.s	get_channel_amplitude
	lea	pt_audchan2temp(pc),a0
	lea	vm_audio_channel2_info(pc),a1
	bsr.s	get_channel_amplitude
	lea	pt_audchan3temp(pc),a0
	lea	vm_audio_channel3_info(pc),a1
	bsr.s	get_channel_amplitude
	lea	pt_audchan4temp(pc),a0
	lea	vm_audio_channel4_info(pc),a1
	bsr.s	get_channel_amplitude
	rts


; Input
; d2.w	Scaling
; a0.l	Temporary audio channel structure
; a1.l	Channel info structure
; Result
	CNOP 0,4
get_channel_amplitude
	tst.b	n_notetrigger(a0)	; new note played ?
	bne.s	get_channel_amplitude_quit
	move.b	#FALSE,n_notetrigger(a0)
	move.w	n_currentperiod(a0),d0
	DIVUF.W d2,d0,d1
	moveq	#vm_max_period_step,d0
	sub.w	d1,d0			; maxperstep - perstep
	lsr.w	#1,d0
	move.w	d0,(a1)+		; speed
	lsr.w	#1,d0
	move.w	d0,(a1)+		; step2 angle speed
	move.w	n_currentvolume(a0),d0
	DIVUF.W d3,d0,d1
	move.w	d1,(a1)+		; step2 angle step
get_channel_amplitude_quit
	rts


	CNOP 0,4
vert_colorscroll3111
	movem.l a3-a6,-(a7)
	move.l	a7,save_a7(a3)	
	moveq	#vm_source_chan1,d1
	MULUF.W audio_channel_info_size/WORD_SIZE,d1,d0
	move.w	vcs3111_bplam_table_start(a3),d2
	move.w	d2,d0		
	move.w	vcs3111_step2_angle(a3),d4
	IFEQ vcs3111_bplam_table_length_256
		add.b (vm_audio_channel1_info+aci_speed+1,pc,d1.w*2),d0 ; increase start value
	ELSE
		add.w	(vm_audio_channel1_info+aci_speed,pc,d1.w*2),d0 ; increase start value
		MOVEF.W vcs3111_bplam_table_size-1,d3 ; overlow number of entries
		and.w	d3,d0		; remove overflow
	ENDC
	move.w	d0,vcs3111_bplam_table_start(a3) 
	move.w	d4,d0		
	moveq	#vm_source_chan2,d1
	MULUF.W audio_channel_info_size/WORD_SIZE,d1,d6
	add.b	(vm_audio_channel1_info+aci_step2_anglespeed+1,pc,d1.w*2),d0 ; next y angle
	move.w	d0,vcs3111_step2_angle(a3) 
	MOVEF.L (cl2_extension1_size*(cl2_display_y_size/2))+4,d5
	move.l	extra_memory(a3),a0	; bplam table
	move.l	cl2_construction2(a3),a1 
	ADDF.W	cl2_extension1_entry+cl2_ext1_BPLCON4_1+WORD_SIZE+(((cl2_display_width/2)-1)*LONGWORD_SIZE)+(((cl2_display_y_size/2)-1)*cl2_extension1_size),a1 ; 2nd quadrant
	lea	LONGWORD_SIZE(a1),a2	; 1st quadrant
	lea	sine_table(pc),a3	
	lea	cl2_extension1_size(a1),a4 ; 3rd quadrant
	lea	cl2_extension1_size(a2),a5 ; 4th quadrant
	move.w	#cl2_extension1_size,a6
	move.w	#(cl2_extension1_size*(cl2_display_y_size/2))-4,a7
	moveq	#vm_source_chan3,d1
	MULUF.W audio_channel_info_size/WORD_SIZE,d1,d6
	move.w	(vm_audio_channel1_info+aci_step2_anglestep,pc,d1.w*2),d7
	swap	d7			; high word: angle step
	move.w	#(cl2_display_width/2)-1,d7 ; low word: loop counter
vert_colorscroll3111_loop1
	swap	d7			; low word: angle step
	move.w	d2,d1			; start value
	MOVEF.W (cl2_display_y_size/2)-1,d6
vert_colorscroll3111_loop2
	move.b	(a0,d1.w),d0		; BPLAM
	move.b	d0,(a1)			; BPLCON4 high
	sub.l	a6,a1			; 2nd quadrant penultimate line
	move.b	d0,(a2)			; BPLCON4 high
	sub.l	a6,a2			; 1st quadrant penultimate line
	move.b	d0,(a4)			; BPLCON4 high
	add.l	a6,a4			; 3rd qudarant next line
	move.b	d0,(a5)			; BPLCON4 high
	IFEQ vcs3111_bplam_table_length_256
		subq.b	#vcs3111_step1,d1 ; next BPLAM
	ELSE
		subq.w	#vcs3111_step1,d1 ; next BPLAM
		and.w	d3,d1		; remove overflow
	ENDC
	add.l	a6,a5			; 4th qudarant next line
	dbf	d6,vert_colorscroll3111_loop2
	move.l	(a3,d4.w*4),d0		; sin(w)
	MULUF.L vcs3111_step2_radius*2,d0 ; y' = (yr*sin(w))/2^15
	add.b	d7,d4			; next y angle
	swap	d0
	add.w	#vcs3111_step2_center,d0
	IFEQ vcs3111_bplam_table_length_256
		sub.b	d0,d2		; decrement start value
	ELSE
		sub.w	d0,d2		; decrement start value
		and.w	d3,d2		; remove overflow
	ENDC
	swap	d7			; low word: loop counter
	add.l	a7,a1			; 2nd quadrant penultimate column
	add.l	d5,a2			; 1st quadrant next column
	sub.l	d5,a4			; 3rd quadrant penultimate column
	sub.l	a7,a5			; 4th quadrant next column
	dbf	d7,vert_colorscroll3111_loop1
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a3-a6
	rts


	CNOP 0,4
vert_scrolltext
	movem.l a4-a5,-(a7)
	tst.w	vst_active(a3)
	bne.s	vert_scrolltext_quit
	move.l	spr_pointers_construction+(2*LONGWORD_SIZE)(pc),d3 ; sprite2 structure
	ADDF.L	(spr_pixel_per_datafetch/4),d3 ; skip sprite header
	move.w	#((vst_copy_blit_y_size)<<6)|(vst_copy_blit_x_size/WORD_BITS),d4 ; BLTSIZE
	MOVEF.W vst_text_char_y_restart,d5
	lea	vst_chars_y_positions(pc),a0
	lea	vst_chars_image_pointers(pc),a1
	lea	BLTAPT-DMACONR(a6),a2
	lea	BLTDPT-DMACONR(a6),a4
	lea	BLTSIZE-DMACONR(a6),a5
	bsr.s	vert_scrolltext_init
	moveq	#vst_text_chars_number-1,d7
vert_scrolltext_loop
	moveq	#0,d0
	move.w	(a0),d0			; y
	move.w	d0,d2
	MULUF.L vst_object_width*vst_object_depth,d0,d1 ; y offset
	add.l	d3,d0			; add sprite2 structure
	WAITBLIT
	move.l	(a1)+,(a2)		; character image
	move.l	d0,(a4)			; sprite0 structure
	move.w	d4,(a5)			; start blit operation
	subq.w	#vst_vert_scroll_speed,d2
	bpl.s	vert_scrolltext_skip
	move.l	a0,-(a7)
	bsr.s	vst_get_new_char_image
	move.l	(a7)+,a0
	move.l	d0,-LONGWORD_SIZE(a1)	; character image
	add.w	d5,d2			; restart y position
vert_scrolltext_skip
	move.w	d2,(a0)+		; y position
	dbf	d7,vert_scrolltext_loop
	move.w	#DMAF_BLITHOG,DMACON-DMACONR(a6)
vert_scrolltext_quit
	movem.l (a7)+,a4-a5
	rts
	CNOP 0,4
vert_scrolltext_init
	move.w	#DMAF_BLITHOG|DMAF_SETCLR,DMACON-DMACONR(a6)
	WAITBLIT
	move.l	#(BC0F_SRCA|BC0F_DEST|ANBNC|ANBC|ABNC|ABC)<<16,BLTCON0-DMACONR(a6) ; minterm D = A
	moveq	#-1,d0
	move.l	d0,BLTAFWM-DMACONR(a6)
	move.l	#((vst_image_plane_width-vst_text_char_width)<<16)|((vst_object_width-vst_text_char_width)+(spr_x_size2/8)),BLTAMOD-DMACONR(a6) ; A&D moduli
	rts


	GET_NEW_CHAR_IMAGE.W vst


	IFEQ open_border_enabled
		CNOP 0,4
blind_fader_in
		move.l	a4,-(a7)
		tst.w	bfi_active(a3)
		bne.s	blind_fader_in_quit
		move.w	bf_registers_table_start(a3),d2
		move.w	d2,d0
		addq.w	#bf_speed,d0	; increase table start
		cmp.w	#bf_registers_table_length/2,d0 ; end of table ?
		ble.s	blind_fader_in_skip
		move.w	#FALSE,bfi_active(a3)
blind_fader_in_skip
		move.w	d0,bf_registers_table_start(a3)
		MOVEF.W	bf_registers_table_length-1,d3
		MOVEF.L cl2_extension1_size,d4
		MOVEF.W	bf_step2,d5
		lea	bf_registers_table(pc),a0
		IFNE cl2_size1
			move.l	cl2_construction1(a3),a1
			ADDF.W	cl2_extension1_entry+cl2_ext1_BPL1DAT,a1
		ENDC
		IFNE cl2_size2
			move.l	cl2_construction2(a3),a2
			ADDF.W	cl2_extension1_entry+cl2_ext1_BPL1DAT,a2
		ENDC
		IFNE cl2_size3
			move.l	cl2_display(a3),a4
			ADDF.W	cl2_extension1_entry+cl2_ext1_BPL1DAT,a4
		ENDC
		moveq	#bf_lamellas_number-1,d7
blind_fader_in_loop1
		move.w	d2,d1		; table start
		moveq	#bf_lamella_height-1,d6
blind_fader_in_loop2
		move.w	(a0,d1.w*2),d0	; register offset
		addq.w	#bf_step1,d1	; next entry
		IFNE cl2_size1
			move.w	d0,(a1)	; CMOVE 0,offset
			add.l	d4,a1	; next line
		ENDC
		IFNE cl2_size2
			move.w	d0,(a2)
			add.l	d4,a2
		ENDC
		IFNE cl2_size3
			move.w	d0,(a4)
			add.l	d4,a4
		ENDC
		and.w	d3,d1		; remove overflow
		dbf	d6,blind_fader_in_loop2
		add.w	d5,d2		; increase table start
		and.w	d3,d2		; remove overflow
		dbf	d7,blind_fader_in_loop1
blind_fader_in_quit
		move.l	(a7)+,a4
		rts


		CNOP 0,4
blind_fader_out
		move.l	a4,-(a7)
		tst.w	bfo_active(a3)
		bne.s	blind_fader_out_quit
		move.w	bf_registers_table_start(a3),d2
		move.w	d2,d0
		subq.w	#bf_speed,d0		; decrease table start
		bpl.s	blind_fader_out_skip1
		move.w	#FALSE,bfo_active(a3)
		bra.s	blind_fader_out_skip2
		CNOP 0,4
blind_fader_out_skip1
		move.w	d0,bf_registers_table_start(a3)
blind_fader_out_skip2
		MOVEF.W	bf_registers_table_length-1,d3
		MOVEF.L cl2_extension1_size,d4
		MOVEF.W	bf_step2,d5
		lea	bf_registers_table(pc),a0
		IFNE cl2_size1
			move.l	cl2_construction1(a3),a1
			ADDF.W	cl2_extension1_entry+cl2_ext1_BPL1DAT,a1
		ENDC
		IFNE cl2_size2
			move.l	cl2_construction2(a3),a2
			ADDF.W	cl2_extension1_entry+cl2_ext1_BPL1DAT,a2
		ENDC
		IFNE cl2_size3
			move.l	cl2_display(a3),a4
			ADDF.W	cl2_extension1_entry+cl2_ext1_BPL1DAT,a4
		ENDC
		moveq	#bf_lamellas_number-1,d7
blind_fader_out_loop1
		move.w	d2,d1		; table start
		moveq	#bf_lamella_height-1,d6
blind_fader_out_loop2
		move.w	(a0,d1.w*2),d0	; register offset
		addq.w	#bf_step1,d1	; next entry
		IFNE cl2_size1
			move.w	d0,(a1)	; CMOVE 0,offset
			add.l	d4,a1	; next line
		ENDC
		IFNE cl2_size2
			move.w	d0,(a2)
			add.l	d4,a2
		ENDC
		IFNE cl2_size3
			move.w	d0,(a4)
			add.l	d4,a4
		ENDC
		and.w	d3,d1		; remove overflow
		dbf	d6,blind_fader_out_loop2
		add.w	d5,d2		; increase table start
		and.w	d3,d2		; remove overflow
		dbf	d7,blind_fader_out_loop1
blind_fader_out_quit
		move.l	(a7)+,a4
		rts
	ENDC


	CNOP 0,4
mouse_handler
	btst	#CIAB_GAMEPORT0,CIAPRA(a4) ; LMB pressed ?
	beq.s	mh_exit_demo
	rts
	CNOP 0,4
mh_exit_demo
	moveq	#FALSE,d1
	move.w	d1,pt_effects_handler_active(a3)
	moveq	#TRUE,d0
	move.w	d0,pt_music_fader_active(a3)
; Blind-Fader
	tst.w	bfi_active(a3)		; fader still running ?
	bne.s	mh_exit_demo_skip	; force fader stop
	move.w	d1,bfi_active(a3)
mh_exit_demo_skip
	move.w	d0,bfo_active(a3)
	rts


	INCLUDE "int-autovectors-handlers.i"

	IFEQ pt_ciatiming_enabled
		CNOP 0,4
ciab_ta_interrupt_server
	ELSE
		CNOP 0,4
vertb_interrupt_server
	ENDC


; PT-Replay
	IFEQ pt_music_fader_enabled
		bsr.s	pt_music_fader
		bra.s	pt_PlayMusic

		PT_FADE_OUT_VOLUME stop_fx_active
		CNOP 0,4
	ENDC

	IFD PROTRACKER_VERSION_2 
		PT2_REPLAY pt_effects_handler
	ENDC
	IFD PROTRACKER_VERSION_3
		PT3_REPLAY pt_effects_handler
	ENDC

	CNOP 0,4
pt_effects_handler
	tst.w	pt_effects_handler_active(a3)
	bne.s	pt_effects_handler_quit
	move.b	n_cmdlo(a2),d0
	cmp.b	#$10,d0
	beq.s	pt_start_blind_fader_in
	cmp.b	#$20,d0
	beq.s	pt_start_scrolltext
pt_effects_handler_quit
	rts
	CNOP 0,4
pt_start_blind_fader_in
	clr.w	bfi_active(a3)
	rts
	CNOP 0,4
pt_start_scrolltext
	clr.w	vst_active(a3)
	rts

	CNOP 0,4
ciab_tb_interrupt_server
	PT_TIMER_INTERRUPT_SERVER

	CNOP 0,4
exter_interrupt_server
	rts

	CNOP 0,4
nmi_interrupt_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,4
pf1_rgb8_color_table
	INCLUDE "NoPlayfields:colortables/color-gradient.ct"


	CNOP 0,4
spr_pointers_construction
	DS.L spr_number


	CNOP 0,4
spr_pointers_display
	DS.L spr_number


	CNOP 0,4
sine_table
	INCLUDE "sine-table-256x32.i"


; PT-Replay
	INCLUDE "music-tracker/pt-invert-table.i"

	INCLUDE "music-tracker/pt-vibrato-tremolo-table.i"

	IFD PROTRACKER_VERSION_2 
		INCLUDE "music-tracker/pt2-period-table.i"
	ENDC
	IFD PROTRACKER_VERSION_3
		INCLUDE "music-tracker/pt3-period-table.i"
	ENDC

	INCLUDE "music-tracker/pt-temp-channel-data-tables.i"

	INCLUDE "music-tracker/pt-sample-starts-table.i"

	INCLUDE "music-tracker/pt-finetune-starts-table.i"


; Volume-Meter
	CNOP 0,2
vm_audio_channel1_info
	DS.B audio_channel_info_size

	CNOP 0,2
vm_audio_channel2_info
	DS.B audio_channel_info_size

	CNOP 0,2
vm_audio_channel3_info
	DS.B audio_channel_info_size

	CNOP 0,2
vm_audio_channel4_info
	DS.B audio_channel_info_size


; Vert-Scrolltext
vst_ascii
	DC.B "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?-'():\/#* "
vst_ascii_end
	EVEN

	CNOP 0,2
vst_chars_offsets
	DS.W vst_ascii_end-vst_ascii
	
	CNOP 0,2
vst_chars_y_positions
	DS.W vst_text_chars_number

	CNOP 0,4
vst_chars_image_pointers
	DS.L vst_text_chars_number


; Blind-Fader
	IFEQ open_border_enabled
		CNOP 0,2
bf_registers_table
		REPT bf_registers_table_length/2
		DC.W NOOP
		ENDR
		REPT bf_registers_table_length/2
		DC.W BPL1DAT
		ENDR
	ENDC


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"


; Vert-Scrolltext
vst_text
	REPT vst_text_chars_number/((vst_origin_char_y_size+1)/vst_text_char_y_size)
	DC.B " "
	ENDR
	DC.B "RESISTANCE IS BACK WITH ANOTHER INTRO CALLED  * NO PLAYFIELDS * "

	REPT vst_text_chars_number/((vst_origin_char_y_size+1)/vst_text_char_y_size)
	DC.B " "
	ENDR
	DC.B "GREETINGS FLY TO   "
	DC.B "ALL AT DEADLINE 2025 # "
	DC.B "BOOM! # "
	DC.B "DESIRE # "
	DC.B "FOCUS DESIGN # "
	DC.B "MYSTIC # "
	DC.B "OXYGENE # "
	DC.B "POO-BRAIN # "
	DC.B "GHOSTOWN # "
	DC.B "PLANET JAZZ # "
	DC.B "THE ELECTRONIC KNIGHTS # "
	DC.B "SPREADPOINT # "
	DC.B "VISION FACTORY   "

	REPT vst_text_chars_number/((vst_origin_char_y_size+1)/vst_text_char_y_size)
	DC.B " "
	ENDR
	DC.B "THE CREDITS   "
	DC.B "CODING BY DISSIDENT   "
	DC.B "GRAPHICS BY GRASS   "
	DC.B "MUSIC BY MA2E   "

	REPT vst_text_chars_number/((vst_origin_char_y_size+1)/vst_text_char_y_size)
	DC.B " "
	ENDR
	DC.B "TEXT RESTARTS..."
	REPT vst_text_chars_number/((vst_origin_char_y_size+1)/vst_text_char_y_size)
	DC.B " "
	ENDR

	DC.B FALSE
	EVEN


	DC.B "$VER: "
	DC.B "RSE-NoPlayfields "
	DC.B "1.0 "
	DC.B "(20.9.25) "
	DC.B "� 2025 by Resistance",0
	EVEN


; Audio data

; PT-Replay
	IFEQ pt_split_module_enabled
pt_auddata			SECTION pt_audio,DATA
		INCBIN "NoPlayfields:trackermodules/MOD.alive and trashy.song"
pt_audsmps			SECTION pt_audio2,DATA_C
		INCBIN "NoPlayfields:trackermodules/MOD.alive and trashy.smps"
	ELSE
pt_auddata			SECTION pt_audio,DATA_C
		INCBIN "NoPlayfields:trackermodules/mod.alive and trashy"
	ENDC


; Gfx data

; Logo
lg_image_data			SECTION lg_gfx,DATA
	INCBIN "NoPlayfields:graphics/32x256x16-Resistance.rawblit"

; Vert-Scrolltext
vst_image_data			SECTION vst_gfx,DATA_C
	INCBIN "NoPlayfields:fonts/16x15x2-Font.rawblit"
	DS.B vst_image_plane_width*vst_image_depth ; empty line

	END
