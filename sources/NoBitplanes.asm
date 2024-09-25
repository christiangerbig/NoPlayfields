; ##############################
; # Programm: NoBitplanes.asm  #
; # Autor:    Christian Gerbig #
; # Datum:    02.06.2024       #
; # Version:  1.1 Beta         #
; # CPU:      68020+           #
; # FASTMEM:  -                #
; # Chipset:  AGA              #
; # OS:       3.0+             #
; ##############################

; V.1.0 Beta
; Erstes Release

; V.1.1
; überarbeitete Includes integriert

; PT 8xy-Befehl
; 810 Start Blind-Fader-In
; 820 Start Scrolltext

; Ausführungszeit 68020: 199 Rasterzeilen


  SECTION code_and_variables,CODE

  MC68040


  INCDIR "Daten:include3.5/"

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

  INCDIR "Daten:Asm-Sources.AGA/normsource-includes/"


PROTRACKER_VERSION_3.0B         SET 1


  INCLUDE "macros.i"


  INCLUDE "equals.i"

requires_030_cpu                EQU FALSE  
requires_040_cpu                EQU FALSE
requires_060_cpu                EQU FALSE
requires_fast_memory            EQU FALSE
requires_multiscan_monitor      EQU FALSE

workbench_start_enabled         EQU FALSE
screen_fader_enabled          EQU FALSE
text_output_enabled             EQU FALSE

open_border_enabled             EQU TRUE

  IFD PROTRACKER_VERSION_2.3A 
    INCLUDE "music-tracker/pt2-equals.i"
  ENDC
  IFD PROTRACKER_VERSION_3.0B
    INCLUDE "music-tracker/pt3-equals.i"
  ENDC
pt_ciatiming_enabled            EQU TRUE
pt_finetune_enabled             EQU FALSE
  IFD PROTRACKER_VERSION_3.0B
pt_metronome_enabled            EQU FALSE
  ENDC
pt_mute_enabled                 EQU FALSE
pt_track_volumes_enabled        EQU TRUE
pt_track_periods_enabled        EQU TRUE
pt_music_fader_enabled          EQU TRUE
pt_split_module_enabled         EQU TRUE
pt_usedfx                       EQU %1011110101111111
pt_usedefx                      EQU %0000000000000000

vcs3111_switch_table_length_256 EQU TRUE

  IFEQ open_border_enabled
dma_bits                        EQU DMAF_SPRITE+DMAF_BLITTER+DMAF_COPPER+DMAF_MASTER+DMAF_SETCLR
  ELSE
dma_bits                        EQU DMAF_SPRITE+DMAF_BLITTER+DMAF_COPPER+DMAF_RASTER+DMAF_MASTER+DMAF_SETCLR
  ENDC

  IFEQ pt_ciatiming_enabled
intena_bits                     EQU INTF_EXTER+INTF_INTEN+INTF_SETCLR
  ELSE
intena_bits                     EQU INTF_VERTB+INTF_EXTER+INTF_INTEN+INTF_SETCLR
  ENDC

ciaa_icr_bits                   EQU CIAICRF_SETCLR
  IFEQ pt_ciatiming_enabled
ciab_icr_bits                   EQU CIAICRF_TA+CIAICRF_TB+CIAICRF_SETCLR
  ELSE
ciab_icr_bits                   EQU CIAICRF_TB+CIAICRF_SETCLR
  ENDC

copcon_bits                     EQU 0

pf1_x_size1                     EQU 0
pf1_y_size1                     EQU 0
pf1_depth1                      EQU 0
pf1_x_size2                     EQU 0
pf1_y_size2                     EQU 0
pf1_depth2                      EQU 0
  IFEQ open_border_enabled
pf1_x_size3                     EQU 0
pf1_y_size3                     EQU 0
pf1_depth3                      EQU 0
  ELSE
pf1_x_size3                     EQU 32
pf1_y_size3                     EQU 1
pf1_depth3                      EQU 1
  ENDC
pf1_colors_number               EQU 0 ;256

pf2_x_size1                     EQU 0
pf2_y_size1                     EQU 0
pf2_depth1                      EQU 0
pf2_x_size2                     EQU 0
pf2_y_size2                     EQU 0
pf2_depth2                      EQU 0
pf2_x_size3                     EQU 0
pf2_y_size3                     EQU 0
pf2_depth3                      EQU 0
pf2_colors_number               EQU 0
pf_colors_number                EQU pf1_colors_number+pf2_colors_number
pf_depth                        EQU pf1_depth3+pf2_depth3

pf_extra_number                 EQU 0

spr_number                      EQU 8
spr_x_size1                     EQU 32
spr_x_size2                     EQU 32
spr_depth                       EQU 2
spr_colors_number               EQU 0 ;4
spr_odd_color_table_select      EQU 14 ;Logo
spr_even_color_table_select     EQU 1 ;Scrolltext (9)
spr_used_number                 EQU 1
spr_swap_number                 EQU 1

  IFD PROTRACKER_VERSION_2.3A 
audio_memory_size               EQU 0
  ENDC
  IFD PROTRACKER_VERSION_3.0B
audio_memory_size               EQU 2
  ENDC

disk_memory_size                EQU 0

chip_memory_size                EQU 0
  IFEQ pt_ciatiming_enabled
ciab_cra_bits                   EQU CIACRBF_LOAD
  ENDC
ciab_crb_bits                   EQU CIACRBF_LOAD+CIACRBF_RUNMODE ;Oneshot mode
ciaa_ta_time                    EQU 0
ciaa_tb_time                    EQU 0
  IFEQ pt_ciatiming_enabled
ciab_ta_time                    EQU 14187 ;= 0.709379 MHz * [20000 µs = 50 Hz duration for one frame on a PAL machine]
;ciab_ta_time                    EQU 14318 ;= 0.715909 MHz * [20000 µs = 50 Hz duration for one frame on a NTSC machine]
  ELSE
ciab_ta_time                    EQU 0
  ENDC
ciab_tb_time                    EQU 362 ;= 0.709379 MHz * [511.43 µs = Lowest note period C1 with Tuning=-8 * 2 / PAL clock constant = 907*2/3546895 ticks per second]
                                        ;= 0.715909 MHz * [506.76 µs = Lowest note period C1 with Tuning=-8 * 2 / NTSC clock constant = 907*2/3579545 ticks per second]
ciaa_ta_continuous_enabled      EQU FALSE
ciaa_tb_continuous_enabled      EQU FALSE
  IFEQ pt_ciatiming_enabled
ciab_ta_continuous_enabled      EQU TRUE
  ELSE
ciab_ta_continuous_enabled      EQU FALSE
  ENDC
ciab_tb_continuous_enabled      EQU FALSE

beam_position                   EQU $133 ;Wegen Module-Fader

  IFNE open_border_enabled 
pixel_per_line                  EQU 32
  ENDC
visible_pixels_number           EQU 352
visible_lines_number            EQU 256
MINROW                          EQU VSTART_256_LINES

  IFNE open_border_enabled 
pf_pixel_per_datafetch          EQU 16 ;1x
  ENDC
spr_pixel_per_datafetch         EQU 32 ;2x

display_window_hstart           EQU HSTART_44_CHUNKY_PIXEL
display_window_vstart           EQU MINROW
display_window_hstop            EQU HSTOP_44_CHUNKY_PIXEL
display_window_vstop            EQU VSTOP_256_LINES

  IFNE open_border_enabled 
pf1_plane_width                 EQU pf1_x_size3/8
data_fetch_width                EQU pixel_per_line/8
pf1_plane_moduli                EQU -(pf1_plane_width-(pf1_plane_width-data_fetch_width))
  ENDC

  IFEQ open_border_enabled
diwstrt_bits                    EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)+(display_window_hstart&$ff)
diwstop_bits                    EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)+(display_window_hstop&$ff)
bplcon0_bits                    EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0)
bplcon3_bits1                   EQU BPLCON3F_SPRES0
bplcon3_bits2                   EQU bplcon3_bits1+BPLCON3F_LOCT
bplcon4_bits                    EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)+(BPLCON4F_ESPRM4*spr_even_color_table_select)
diwhigh_bits                    EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_vstart&$700)>>8)
fmode_bits                      EQU FMODEF_SPR32
  ELSE
diwstrt_bits                    EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)+(display_window_hstart&$ff)
diwstop_bits                    EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)+(display_window_hstop&$ff)
ddfstrt_bits                    EQU DDFSTART_OVERSCAN_32_PIXEL
ddfstop_bits                    EQU DDFSTOP_OVERSCAN_32_PIXEL_MIN
bplcon0_bits                    EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) 
bplcon3_bits1                   EQU BPLCON3F_SPRES0
bplcon3_bits2                   EQU bplcon3_bits1+BPLCON3F_LOCT
bplcon4_bits                    EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)+(BPLCON4F_ESPRM4*spr_even_color_table_select)
diwhigh_bits                    EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_vstart&$700)>>8)
fmode_bits                      EQU FMODEF_SPR32
  ENDC
color00_bits                    EQU $001122

cl2_display_x_size              EQU 352
cl2_display_width               EQU cl2_display_x_size/8
cl2_display_y_size              EQU visible_lines_number
  IFEQ open_border_enabled
cl2_hstart1                     EQU display_window_hstart-(1*CMOVE_SLOT_PERIOD)-4
  ELSE
cl2_hstart1                     EQU display_window_hstart-4
  ENDC
cl2_vstart1                     EQU MINROW
cl2_hstart2                     EQU $00
cl2_vstart2                     EQU beam_position&$ff

sine_table_length               EQU 256

; **** Logo ****
lg_image_x_size                 EQU 32
lg_image_plane_width            EQU lg_image_x_size/8
lg_image_y_size                 EQU 256
lg_image_depth                  EQU 16

lg_image_x_position             EQU display_window_hstart
lg_image_y_position             EQU display_window_vstart

; **** PT-Replay ****
pt_fade_out_delay               EQU 1 ;Tick

; **** Volume-Meter ****
vm_source_channel1              EQU 2
vm_source_channel2              EQU 3
vm_source_channel3              EQU 3
vm_period_div                   EQU 11
vm_max_period_step              EQU 9
vm_volume_div                   EQU 6

; **** Vert-Colorscroll 3.1.1.1 ****
vcs3111_bar_height              EQU 128
vcs3111_bars_number             EQU 2
vcs3111_step1                   EQU 1
vcs3111_step2_min               EQU 5
vcs3111_step2_max               EQU 13
vcs3111_step2                   EQU vcs3111_step2_max-vcs3111_step2_min
vcs3111_step2_radius            EQU vcs3111_step2
vcs3111_step2_center            EQU vcs3111_step2+vcs3111_step2_min

; **** Vertical-Scrolltext ****
vst_used_sprites_number         EQU 1

vst_image_x_size                EQU 320
vst_image_plane_width           EQU vst_image_x_size/8
vst_image_depth                 EQU 1

vst_origin_character_x_size     EQU 16
vst_origin_character_y_size     EQU 15
vst_origin_charcter_depth       EQU vst_image_depth

vst_text_character_x_size       EQU 16
vst_text_character_width        EQU vst_text_character_x_size/8
vst_text_character_y_size       EQU vst_origin_character_y_size+1
vst_text_character_depth        EQU vst_image_depth

vst_vert_scroll_window_x_size   EQU vst_text_character_x_size
vst_vert_scroll_window_width    EQU vst_vert_scroll_window_x_size/8
vst_vert_scroll_window_y_size   EQU visible_lines_number+vst_text_character_y_size
vst_vert_scroll_window_depth    EQU vst_image_depth
vst_vert_scroll_speed           EQU 1

vst_text_character_y_shift_max  EQU vst_text_character_y_size
vst_text_character_y_restart    EQU vst_vert_scroll_window_y_size
vst_text_characters_number      EQU vst_vert_scroll_window_y_size/vst_text_character_y_size

vst_object_x_size               EQU 32
vst_object_width                EQU vst_object_x_size/8
vst_object_y_size               EQU visible_lines_number+(vst_text_character_y_size*2)
vst_object_depth                EQU 2

vst_copy_blit_x_size            EQU vst_text_character_x_size
vst_copy_blit_y_size            EQU vst_text_character_y_size*vst_text_character_depth

; **** Blind-Fader ****
bf_lamella_height               EQU 16
bf_lamellas_number              EQU visible_lines_number/bf_lamella_height
bf_step1                        EQU 1
bf_step2                        EQU 1
bf_speed                        EQU 2

bf_registers_table_length       EQU bf_lamella_height*4


color_step1                     EQU 256/(vcs3111_bar_height/2)
color_values_number1            EQU vcs3111_bar_height/2
segments_number1                EQU vcs3111_bars_number*2

ct_size1                        EQU color_values_number1*segments_number1

vcs3111_switch_table_size       EQU ct_size1

extra_memory_size               EQU vcs3111_switch_table_size*BYTE_SIZE


  INCLUDE "except-vectors-offsets.i"


  INCLUDE "extra-pf-attributes.i"


  INCLUDE "sprite-attributes.i"


  RSRESET

cl1_begin        RS.B 0

  INCLUDE "copperlist1-offsets.i"

cl1_COPJMP2      RS.L 1

copperlist1_size RS.B 0


  RSRESET

cl2_extension1      RS.B 0

cl2_ext1_WAIT       RS.L 1
  IFEQ open_border_enabled 
cl2_ext1_BPL1DAT    RS.L 1
  ENDC
cl2_ext1_BPLCON4_1  RS.L 1
cl2_ext1_BPLCON4_2  RS.L 1
cl2_ext1_BPLCON4_3  RS.L 1
cl2_ext1_BPLCON4_4  RS.L 1
cl2_ext1_BPLCON4_5  RS.L 1
cl2_ext1_BPLCON4_6  RS.L 1
cl2_ext1_BPLCON4_7  RS.L 1
cl2_ext1_BPLCON4_8  RS.L 1
cl2_ext1_BPLCON4_9  RS.L 1
cl2_ext1_BPLCON4_10 RS.L 1
cl2_ext1_BPLCON4_11 RS.L 1
cl2_ext1_BPLCON4_12 RS.L 1
cl2_ext1_BPLCON4_13 RS.L 1
cl2_ext1_BPLCON4_14 RS.L 1
cl2_ext1_BPLCON4_15 RS.L 1
cl2_ext1_BPLCON4_16 RS.L 1
cl2_ext1_BPLCON4_17 RS.L 1
cl2_ext1_BPLCON4_18 RS.L 1
cl2_ext1_BPLCON4_19 RS.L 1
cl2_ext1_BPLCON4_20 RS.L 1
cl2_ext1_BPLCON4_21 RS.L 1
cl2_ext1_BPLCON4_22 RS.L 1
cl2_ext1_BPLCON4_23 RS.L 1
cl2_ext1_BPLCON4_24 RS.L 1
cl2_ext1_BPLCON4_25 RS.L 1
cl2_ext1_BPLCON4_26 RS.L 1
cl2_ext1_BPLCON4_27 RS.L 1
cl2_ext1_BPLCON4_28 RS.L 1
cl2_ext1_BPLCON4_29 RS.L 1
cl2_ext1_BPLCON4_30 RS.L 1
cl2_ext1_BPLCON4_31 RS.L 1
cl2_ext1_BPLCON4_32 RS.L 1
cl2_ext1_BPLCON4_33 RS.L 1
cl2_ext1_BPLCON4_34 RS.L 1
cl2_ext1_BPLCON4_35 RS.L 1
cl2_ext1_BPLCON4_36 RS.L 1
cl2_ext1_BPLCON4_37 RS.L 1
cl2_ext1_BPLCON4_38 RS.L 1
cl2_ext1_BPLCON4_39 RS.L 1
cl2_ext1_BPLCON4_40 RS.L 1
cl2_ext1_BPLCON4_41 RS.L 1
cl2_ext1_BPLCON4_42 RS.L 1
cl2_ext1_BPLCON4_43 RS.L 1
cl2_ext1_BPLCON4_44 RS.L 1

cl2_extension1_size RS.B 0


  RSRESET

cl2_begin            RS.B 0

cl2_extension1_entry RS.B cl2_extension1_size*cl2_display_y_size

cl2_WAIT             RS.L 1
cl2_INTREQ           RS.L 1

cl2_end              RS.L 1

copperlist2_size     RS.B 0


; ** Konstanten für die Größe der Copperlisten **
cl1_size1               EQU 0
cl1_size2               EQU 0
cl1_size3               EQU copperlist1_size

cl2_size1               EQU 0
cl2_size2               EQU copperlist2_size
cl2_size3               EQU copperlist2_size


; ** Sprite0-Zusatzstruktur **
  RSRESET

spr0_extension1       RS.B 0

spr0_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr0_ext1_planedata   RS.L lg_image_y_size*(spr_pixel_per_datafetch/16)

spr0_extension1_size  RS.B 0


; ** Sprite0-Hauptstruktur **
  RSRESET

spr0_begin            RS.B 0

spr0_extension1_entry RS.B spr0_extension1_size

spr0_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite0_size          RS.B 0

; ** Sprite1-Zusatzstruktur **
  RSRESET

spr1_extension1       RS.B 0

spr1_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr1_ext1_planedata   RS.L lg_image_y_size*(spr_pixel_per_datafetch/16)

spr1_extension1_size  RS.B 0

; ** Sprite1-Hauptstruktur **
  RSRESET

spr1_begin            RS.B 0

spr1_extension1_entry RS.B spr1_extension1_size

spr1_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite1_size          RS.B 0

; ** Sprite2-Zusatzstruktur **
  RSRESET

spr2_extension1       RS.B 0

spr2_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr2_ext1_planedata   RS.L 1*(spr_pixel_per_datafetch/16)*vst_object_y_size

spr2_extension1_size  RS.B 0

; ** Sprite2-Hauptstruktur **
  RSRESET

spr2_begin            RS.B 0

spr2_extension1_entry RS.B spr2_extension1_size

spr2_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite2_size          RS.B 0

; ** Sprite3-Hauptstruktur **
  RSRESET

spr3_begin       RS.B 0

spr3_end         RS.L 1*(spr_pixel_per_datafetch/16)

sprite3_size     RS.B 0

; ** Sprite4-Hauptstruktur **
  RSRESET

spr4_begin       RS.B 0

spr4_end         RS.L 1*(spr_pixel_per_datafetch/16)

sprite4_size     RS.B 0

; ** Sprite5-Hauptstruktur **
  RSRESET

spr5_begin       RS.B 0

spr5_end         RS.L 1*(spr_pixel_per_datafetch/16)

sprite5_size     RS.B 0

; ** Sprite6-Hauptstruktur **
  RSRESET

spr6_begin       RS.B 0

spr6_end         RS.L 1*(spr_pixel_per_datafetch/16)

sprite6_size     RS.B 0

; ** Sprite7-Hauptstruktur **
  RSRESET

spr7_begin       RS.B 0

spr7_end         RS.L 1*(spr_pixel_per_datafetch/16)

sprite7_size     RS.B 0

; ** Konstanten für die Größe der Spritestrukturen **
spr0_x_size1     EQU spr_x_size1
spr0_y_size1     EQU sprite0_size/(spr_x_size1/8)
spr1_x_size1     EQU spr_x_size1
spr1_y_size1     EQU sprite1_size/(spr_x_size1/8)
spr2_x_size1     EQU spr_x_size1
spr2_y_size1     EQU sprite2_size/(spr_x_size1/8)
spr3_x_size1     EQU spr_x_size1
spr3_y_size1     EQU sprite3_size/(spr_x_size1/8)
spr4_x_size1     EQU spr_x_size1
spr4_y_size1     EQU sprite4_size/(spr_x_size1/8)
spr5_x_size1     EQU spr_x_size1
spr5_y_size1     EQU sprite5_size/(spr_x_size1/8)
spr6_x_size1     EQU spr_x_size1
spr6_y_size1     EQU sprite6_size/(spr_x_size1/8)
spr7_x_size1     EQU spr_x_size1
spr7_y_size1     EQU sprite7_size/(spr_x_size1/8)

spr0_x_size2     EQU spr_x_size2
spr0_y_size2     EQU sprite0_size/(spr_x_size2/8)
spr1_x_size2     EQU spr_x_size2
spr1_y_size2     EQU sprite1_size/(spr_x_size2/8)
spr2_x_size2     EQU spr_x_size2
spr2_y_size2     EQU sprite2_size/(spr_x_size2/8)
spr3_x_size2     EQU spr_x_size2
spr3_y_size2     EQU sprite3_size/(spr_x_size2/8)
spr4_x_size2     EQU spr_x_size2
spr4_y_size2     EQU sprite4_size/(spr_x_size2/8)
spr5_x_size2     EQU spr_x_size2
spr5_y_size2     EQU sprite5_size/(spr_x_size2/8)
spr6_x_size2     EQU spr_x_size2
spr6_y_size2     EQU sprite6_size/(spr_x_size2/8)
spr7_x_size2     EQU spr_x_size2
spr7_y_size2     EQU sprite7_size/(spr_x_size2/8)


  RSRESET

  INCLUDE "variables-offsets.i"

save_a7                    RS.L 1

; **** PT-Replay ****
  IFD PROTRACKER_VERSION_2.3A 
    INCLUDE "music-tracker/pt2-variables-offsets.i"
  ENDC
  IFD PROTRACKER_VERSION_3.0B
    INCLUDE "music-tracker/pt3-variables-offsets.i"
  ENDC

pt_effects_handler_active  RS.W 1

; **** Vert-Colorscroll 3.1.1.1 ****
vcs3111_switch_table_start RS.W 1
vcs3111_step2_angle        RS.W 1

; **** Vert-Scrolltext ****
  RS_ALIGN_LONGWORD
vst_image                  RS.L 1
vst_enabled        RS.W 1
vst_text_table_start       RS.W 1

; **** Blind-Fader ****
  IFEQ open_border_enabled
bf_registers_table_start   RS.W 1

; **** Blind-Fader-In ****
bfi_active                 RS.W 1

; **** Blind-Fader-Out ****
bfo_active                 RS.W 1
  ENDC

; **** Main ****
fx_active                  RS.W 1

variables_size             RS.B 0


; **** PT-Replay ****
; ** PT-Song-Structure **
  INCLUDE "music-tracker/pt-song.i"

; ** Temporary channel structure **
  INCLUDE "music-tracker/pt-temp-channel.i"

; **** Volume-Meter ****
; ** Structure for channel info **
  RSRESET

vm_audchaninfo         RS.B 0

vm_aci_speed           RS.W 1
vm_aci_step2anglespeed RS.W 1
vm_aci_step2anglestep  RS.W 1

vm_audchaninfo_size    RS.B 0


  INCLUDE "sys-wrapper.i"

  CNOP 0,4
init_main_variables

; **** PT-Replay ****
  IFD PROTRACKER_VERSION_2.3A 
    PT2_INIT_VARIABLES
  ENDC
  IFD PROTRACKER_VERSION_3.0B
    PT3_INIT_VARIABLES
  ENDC

  moveq   #TRUE,d0
  move.w  d0,pt_effects_handler_active(a3)

; **** Vert-Colorscroll 3.1.1.1 ****
  move.w  d0,vcs3111_switch_table_start(a3)
  moveq   #sine_table_length/4,d2
  move.w  d2,vcs3111_step2_angle(a3)

; **** Vert-Scrolltext ****
  lea     vst_image_data,a0
  move.l  a0,vst_image(a3)
  moveq   #FALSE,d1
  move.w  d1,vst_enabled(a3)
  moveq   #0,d0
  move.w  d0,vst_text_table_start(a3)

; **** Blind-Fader ****
  IFEQ open_border_enabled
    move.w  d0,bf_registers_table_start(a3)

; **** Blind-Fader-In ****
    move.w  d1,bfi_active(a3)

; **** Blind-Fader-Out ****
    move.w  d1,bfo_active(a3)
  ENDC

; **** Main ****
  move.w  d1,fx_active(a3)
  rts

; ** Alle Initialisierungsroutinen ausführen **
  CNOP 0,4
init_main
  bsr.s   pt_DetectSysFrequ
  bsr.s   pt_InitRegisters
  bsr     pt_InitAudTempStrucs
  bsr     pt_ExamineSongStruc
  IFEQ pt_finetune_enabled
    bsr     pt_InitFtuPeriodTableStarts
  ENDC
  bsr     vm_init_audio_channel_info_structures
  bsr     vcs3111_init_switch_table
  bsr     vst_init_characters_offsets
  bsr     vst_init_characters_y_positions
  bsr     vst_init_characters_images
  bsr     init_color_registers
  bsr     init_sprites
  bsr     init_CIA_timers
  bsr     init_first_copperlist
  bra     init_second_copperlist

; **** PT-Replay ****
; ** Detect system frequency NTSC/PAL **
  PT_DETECT_SYS_FREQUENCY

; ** Audioregister initialisieren **
   PT_INIT_REGISTERS

; ** Temporäre Audio-Kanal-Struktur initialisieren **
   PT_INIT_AUDIO_TEMP_STRUCTURES

; ** Höchstes Pattern ermitteln und Tabelle mit Zeigern auf Samples initialisieren **
   PT_EXAMINE_SONG_STRUCTURE

  IFEQ pt_finetune_enabled
; ** FineTuning-Offset-Tabelle initialisieren **
    PT_INIT_FINETUNE_TABLE_STARTS
  ENDC

; **** Volume-Meter ****
; ** Audiochandata-Strukturen initialisieren **
  CNOP 0,4
vm_init_audio_channel_info_structures
  lea     vm_audio_channel1_info(pc),a0
  moveq   #0,d0           
  move.w  d0,(a0)+           ;Y-Winkel Geschwindigkeit
  move.w  d0,(a0)+           ;Y-Winkel Schrittweite
  move.w  d0,(a0)+      
  move.w  d0,(a0)+           ;Y-Winkel Geschwindigkeit
  move.w  d0,(a0)+           ;Y-Winkel Schrittweite
  move.w  d0,(a0)+      
  move.w  d0,(a0)+           ;Y-Winkel Geschwindigkeit
  move.w  d0,(a0)+           ;Y-Winkel Schrittweite
  move.w  d0,(a0)+      
  move.w  d0,(a0)+           ;Y-Winkel Geschwindigkeit
  move.w  d0,(a0)+           ;Y-Winkel Schrittweite
  move.w  d0,(a0)
  rts

; **** Vert-Colorscroll ****
; ** Referenz-Switchtabelle initialisieren **
  INIT_SWITCH_TABLE.B vcs3111,0,1,color_values_number1*segments_number1,extra_memory,a3

; ** Offsets der Buchstaben im Characters-Pic berechnen **
  INIT_CHARACTERS_OFFSETS.W vst

; ** X-Positionen der Chars berechnen **
  INIT_CHARACTERS_Y_POSITIONS vst

; ** Laufschrift initialisieren **
  INIT_CHARACTERS_IMAGES vst


  CNOP 0,4
init_color_registers
  CPU_SELECT_COLOR_HIGH_BANK 0
  CPU_INIT_COLOR_HIGH COLOR00,32,pf1_color_table
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
  CPU_INIT_COLOR_LOW COLOR00,32,pf1_color_table
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
  bsr.s   spr_init_pointers_table
  bsr.s   lg_init_sprites
  bsr     vst_init_xy_coordinates
  bra     spr_copy_structures

  INIT_SPRITE_POINTERS_TABLE

; **** Logo ****
  CNOP 0,4
lg_init_sprites
  move.w  #lg_image_x_position*4,d0 ;X-Koord.
  moveq   #lg_image_y_position,d1 ;Y-Koord.
  move.w  #lg_image_y_size,d2 ;Höhe
  add.w   d1,d2              ;Höhe zu Y dazuaddieren
  lea     spr_pointers_construction(pc),a2 ;Zeiger auf Sprites
  SET_SPRITE_POSITION d0,d1,d2
  move.l  (a2)+,a0           ;1. Sprite-Struktur (SPR0)
  move.w  d1,(a0)            ;SPRxPOS
  move.w  d2,spr_pixel_per_datafetch/8(a0) SPRxCTL
  ADDF.W  (spr_pixel_per_datafetch/4),a0 ;Sprite-Header überspringen
  move.l  (a2),a1            ;2. Sprite-Struktur (SPR1)
  move.w  d1,(a1)            ;SPRxPOS
  tas     d2                 ;Attached-Bit setzen
  move.w  d2,spr_pixel_per_datafetch/8(a1) SPRxCTL
  ADDF.W  (spr_pixel_per_datafetch/4),a1 ;Sprite-Header überspringen
  lea     lg_image_data,a2   ;Zeiger auf Grafikdaten
  MOVEF.W lg_image_y_size-1,d7 ;Höhe des Einzelsprites
lg_init_sprites_loop
  move.l  (a2)+,(a0)+        ;Plane0 32 Pixel
  move.l  (a2)+,(a0)+        ;Plane1 32 Pixel
  move.l  (a2)+,(a1)+        ;Plane2 32 Pixel
  move.l  (a2)+,(a1)+        ;Plane3 32 Pixel
  dbf     d7,lg_init_sprites_loop
  rts

; **** Vert-Scrolltext ****
; ** Sprite-Koordinaten initialisieren **
  CNOP 0,4
vst_init_xy_coordinates
  move.w  #(display_window_hstop-vst_text_character_x_size)*4,d0 ;X-Koord.
  moveq   #display_window_vstart-vst_text_character_y_size,d1 ;Y-Koord.
  move.w  #vst_object_y_size,d2 ;Höhe
  add.w   d1,d2              ;Höhe zu Y dazuaddieren
  move.l  spr_pointers_construction+(2*LONGWORD_SIZE)(pc),a0 ;Sprite2-Struktur
  SET_SPRITE_POSITION d0,d1,d2
  move.w  d1,(a0)            ;SPRxPOS
  move.w  d2,spr_pixel_per_datafetch/8(a0) SPRxCTL
  rts

  COPY_SPRITE_STRUCTURES


  CNOP 0,4
init_CIA_timers

; **** PT-Replay ****
  PT_INIT_TIMERS
  rts

  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0
  bsr.s   cl1_init_playfield_registers
  bsr     cl1_init_sprite_pointers
  IFEQ open_border_enabled
    COP_MOVEQ TRUE,COPJMP2
    bra     cl1_set_sprite_pointers
  ELSE
    bsr.s   cl1_init_bitplane_pointers
    COP_MOVEQ TRUE,COPJMP2
    bsr     cl1_set_sprite_pointers
    bra     cl1_set_bitplane_pointers
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
  move.l  cl2_construction2(a3),a0 
  bsr.s   cl2_init_bplcon4_registers
  bsr.s   cl2_init_copper_interrupt
  COP_LISTEND
  bsr     copy_second_copperlist
  bra     swap_second_copperlist

  COP_INIT_BPLCON4_CHUNKY_SCREEN cl2,cl2_hstart1,cl2_vstart1,cl2_display_x_size,cl2_display_y_size,open_border_enabled,FALSE,FALSE,NOOP<<16

  COP_INIT_COPINT cl2,cl2_hstart2,cl2_vstart2

  COPY_COPPERLIST cl2,2


  CNOP 0,4
main
  bsr.s   no_sync_routines
  bra.s   beam_routines


  CNOP 0,4
no_sync_routines
  rts


  CNOP 0,4
beam_routines
  bsr     wait_copint
  bsr.s   swap_second_copperlist
  bsr.s   spr_swap_structures
  bsr     vert_scrolltext
  bsr     get_channels_amplitudes
  bsr     vert_colorscroll3111
  IFEQ open_border_enabled
    bsr     blind_fader_in
    bsr     blind_fader_out
  ENDC
  bsr     mouse_handler
  tst.w   fx_active(a3)      ;Effekte beendet ?
  bne     beam_routines      ;Nein -> verzweige
  rts


  SWAP_COPPERLIST cl2,2

  SWAP_SPRITES_STRUCTURES spr,spr_swap_number,2


; ** Amplituden der einzelnen Kanäle in Erfahrung bringen **
  CNOP 0,4
get_channels_amplitudes
  moveq   #vm_period_div,d2
  moveq   #vm_volume_div,d3
  lea	  pt_audchan1temp(pc),a0 ;Zeiger auf temporäre Struktur des 1. Kanals
  lea     vm_audio_channel1_info(pc),a1
  bsr.s   get_channel_amplitude
  lea	  pt_audchan2temp(pc),a0 ;Zeiger auf temporäre Struktur des 2. Kanals
  bsr.s   get_channel_amplitude
  lea	  pt_audchan3temp(pc),a0 ;Zeiger auf temporäre Struktur des 3. Kanals
  bsr.s   get_channel_amplitude
  lea	  pt_audchan4temp(pc),a0 ;Zeiger auf temporäre Struktur des 4. Kanals

; ** Routine get-channel-amplitude **
; d2 ... Skalierung
; a0 ... Temporäre Struktur des Audiokanals
; a1 ... Zeiger auf Amplitudenwert des Kanals
get_channel_amplitude
  tst.b   n_note_trigger(a0) ;Neue Note angespielt ?
  bne.s   no_get_channel_amplitude ;Nein -> verzweige
  moveq   #FALSE,d1
  move.b  d1,n_note_trigger(a0) ;Note Trigger Flag zurücksetzen
  move.w  n_period(a0),d0    ;Angespielte Periode 
  DIVUF.W d2,d0,d1
  moveq   #vm_max_period_step,d0
  sub.w   d1,d0              ;maxperstep - perstep
  lsr.w   #1,d0              ;/2
  move.w  d0,(a1)+           ;Geschwindigkeit
  lsr.w   #1,d0              ;/2
  move.w  d0,(a1)+           ;Schrittweite
  move.w  n_current_volume(a0),d0
  DIVUF.W d3,d0,d1
  move.w  d1,(a1)+
no_get_channel_amplitude
  rts

; ** Vertikaler/horizontaler Colorscroll **
  CNOP 0,4
vert_colorscroll3111
  movem.l a3-a6,-(a7)
  move.l  a7,save_a7(a3)     
  moveq   #vm_source_channel1,d1
  MULUF.W vm_audchaninfo_size/2,d1,d0
  move.w  vcs3111_switch_table_start(a3),d2 ;Startwert in Farbtabelle 
  move.w  d2,d0              
  move.w  vcs3111_step2_angle(a3),d4 ;Y-Step-Winkel 
  IFEQ vcs3111_switch_table_length_256
    add.b (vm_audio_channel1_info+vm_aci_speed+1,pc,d1.w*2),d0 ;Startwert der Switchtabelle erhöhen
  ELSE
    MOVEF.W vcs3111_switch_table_size-1,d3 ;Anzahl der Einträge
    add.w   (vm_audio_channel1_info+vm_aci_speed,pc,d1.w*2),d0 ;Startwert der Switchtabelle erhöhen
    and.w   d3,d0            ;Überlauf entfernen
  ENDC
  move.w  d0,vcs3111_switch_table_start(a3) 
  move.w  d4,d0              
  moveq   #vm_source_channel2,d1
  MULUF.W vm_audchaninfo_size/2,d1,d6
  add.b   (vm_audio_channel1_info+vm_aci_step2anglespeed+1,pc,d1.w*2),d0 ;nächster Y-Winkel
  move.w  d0,vcs3111_step2_angle(a3) 
  MOVEF.L (cl2_extension1_size*(cl2_display_y_size/2))+4,d5
  move.l  extra_memory(a3),a0 ;Tabelle mit Switchwerten
  move.l  cl2_construction2(a3),a1 
  ADDF.W  cl2_extension1_entry+cl2_ext1_BPLCON4_1+2+(((cl2_display_width/2)-1)*LONGWORD_SIZE)+(((cl2_display_y_size/2)-1)*cl2_extension1_size),a1 ;Start in CL 2. Quadrant
  lea     LONGWORD_SIZE(a1),a2 ;Start in CL 1. Quadrant
  lea     sine_table(pc),a3  
  lea     cl2_extension1_size(a1),a4 ;Start in CL 3. Quadrant
  lea     cl2_extension1_size(a2),a5 ;Start in CL 4. Quadrant
  move.w  #cl2_extension1_size,a6
  move.w  #(cl2_extension1_size*(cl2_display_y_size/2))-4,a7
  moveq   #vm_source_channel3,d1
  MULUF.W vm_audchaninfo_size/2,d1,d6
  move.w  (vm_audio_channel1_info+vm_aci_step2anglestep,pc,d1.w*2),d7
  swap    d7
  move.w  #(cl2_display_width/2)-1,d7 ;Anzahl der Spalten
vert_colorscroll3111_loop1
  swap    d7                 ;Schrittweite
  move.w  d2,d1              ;Startwert 
  MOVEF.W (cl2_display_y_size/2)-1,d6 ;Effekt für x Zeilen
vert_colorscroll3111_loop2
  move.b  (a0,d1.w),d0       ;Switchwert aus Tabelle
  move.b  d0,(a1)
  sub.l   a6,a1              ;2. Quadrant vorletzte Zeile in CL
  move.b  d0,(a2)
  sub.l   a6,a2              ;1. Quadrant vorletzte Zeile in CL
  move.b  d0,(a4)
  add.l   a6,a4              ;3. Quadrant nächste Zeile in CL
  move.b  d0,(a5)
  IFEQ vcs3111_switch_table_length_256
    subq.b  #vcs3111_step1,d1 ;nächster Wert aus Tabelle
  ELSE
    subq.w  #vcs3111_step1,d1 ;nächster Wert aus Tabelle
    and.w   d3,d1            ;Überlauf entfernen
  ENDC
  add.l   a6,a5              ;4. Quadrant nächste Zeile in CL
  dbf     d6,vert_colorscroll3111_loop2
  move.l  (a3,d4.w*4),d0     ;sin(w)
  MULUF.L vcs3111_step2_radius*2,d0 ;y'=(yr*sin(w))/2^15
  add.b   d7,d4              ;nächster Y-Winkel
  swap    d0
  add.w   #vcs3111_step2_center,d0 ;+ Y-Mittelpunkt
  IFEQ vcs3111_switch_table_length_256
    sub.b   d0,d2            ;Startwert verringern
  ELSE
    sub.w   d0,d2            ;Startwert verringern
    and.w   d3,d2            ;Überlauf entfernen
  ENDC
  swap    d7                 ;Schleifenzähler
  add.l   a7,a1              ;2. Quadrant vorletzte Spalte
  add.l   d5,a2              ;1. Quadrant nächste Spalte
  sub.l   d5,a4              ;3. Quadrant vorletzte Spalte
  sub.l   a7,a5              ;4. Quadrant nächste Spalte
  dbf     d7,vert_colorscroll3111_loop1
  move.l  variables+save_a7(pc),a7 ;Alter Stackpointer
  movem.l (a7)+,a3-a6
  rts

; ** Laufschrift **
  CNOP 0,4
vert_scrolltext
  tst.w   vst_enabled(a3) ;Scrolltext an ?
  bne.s   vst_no_vert_scrolltext ;Nein -> verzweige
  movem.l a4-a5,-(a7)
  move.l  spr_pointers_construction+(2*LONGWORD_SIZE)(pc),d3 ;Sprite2-Struktur
  ADDF.L  (spr_pixel_per_datafetch/4),d3 ;Sprite-Header überspringen
  move.w  #(vst_copy_blit_y_size*64)+(vst_copy_blit_x_size/16),d4 ;BLTSIZE
  MOVEF.W vst_text_character_y_restart,d5
  lea     vst_characters_y_positions(pc),a0 ;Y-Positionen der Chars
  lea     vst_characters_image_pointers(pc),a1 ;Zeiger auf Adressen der Char-Images
  lea     BLTAPT-DMACONR(a6),a2    ;Offset der Blitterregister auf Null setzen
  lea     BLTDPT-DMACONR(a6),a4
  lea     BLTSIZE-DMACONR(a6),a5
  bsr.s   vst_init_copy_blit
  moveq   #vst_text_characters_number-1,d7 ;Anzahl der Chars
vert_scrolltext_loop
  moveq   #0,d0           ;32-Bit-Zugriff
  move.w  (a0),d0            ;Y-Position
  move.w  d0,d2              ;Y retten
  MULUF.L vst_object_width*vst_object_depth,d0 ;Y-Offset
  add.l   d3,d0              ;Y-Offset
  WAITBLIT
  move.l  (a1)+,(a2)         ;Char
  move.l  d0,(a4)            ;Sprite0-Struktur
  move.w  d4,(a5)            ;Blitter starten
  subq.w  #vst_vert_scroll_speed,d2 ;Y-Position reduzieren
  bpl.s   vst_set_character_y_position ;Wenn X >= 0, dann verzweige
  move.l  a0,-(a7)
  bsr.s   vst_get_new_character_image
  move.l  (a7)+,a0
  move.l  d0,-4(a1)          ;Neues Bild für Character
  add.w   d5,d2              ;Y-Pos Neustart
vst_set_character_y_position
  move.w  d2,(a0)+           ;neue Y-Pos retten
  dbf     d7,vert_scrolltext_loop
  move.w  #DMAF_BLITHOG,DMACON-DMACONR(a6) ;BLTPRI aus
  movem.l (a7)+,a4-a5
vst_no_vert_scrolltext
  rts
  CNOP 0,4
vst_init_copy_blit
  move.w  #DMAF_BLITHOG+DMAF_SETCLR,DMACON-DMACONR(a6) ;BLTPRI an
  WAITBLIT
  move.l  #(BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC)<<16,BLTCON0-DMACONR(a6) ;Minterm D=A
  moveq   #FALSE,d0
  move.l  d0,BLTAFWM-DMACONR(a6) ;Ausmaskierung
  move.l  #((vst_image_plane_width-vst_text_character_width)<<16)+((vst_object_width-vst_text_character_width)+(spr_x_size2/8)),BLTAMOD-DMACONR(a6) ;A-Mod + D-Mod
  rts

; ** Neues Image für Character ermitteln **
  GET_NEW_CHARACTER_IMAGE.W vst


; ** Blind-Fader-In **
  IFEQ open_border_enabled
    CNOP 0,4
blind_fader_in
    tst.w   bfi_active(a3)   ;Blind-Fader-In an ?
    bne.s   no_blind_fader_in ;Nein -> verzweige
    move.l  a4,-(a7)
    move.w  bf_registers_table_start(a3),d2 ;Registeradresse 
    move.w  d2,d0            
    addq.w  #bf_speed,d0     ;Startwert der Tabelle erhöhen
    cmp.w   #bf_registers_table_length/2,d0 ;Ende der Tabelle erreicht ?
    ble.s   bf_save_registers_table_start ;Nein -> verzweige
    moveq   #FALSE,d1
    move.w  d1,bfi_active(a3) ;Blind-Fader-In aus
bf_save_registers_table_start
    move.w  d0,bf_registers_table_start(a3) 
    MOVEF.W bf_registers_table_length,d3
    MOVEF.W cl2_extension1_size,d4
    moveq   #bf_step2,d5
    lea     bf_registers_table(pc),a0 ;Tabelle mit Registeradressen
    IFNE cl2_size1
      move.l  cl2_construction1(a3),a1 ;1. CL
      ADDF.W  cl2_extension1_entry+cl2_ext1_BPL1DAT,a1
    ENDC
    IFNE cl2_size2
      move.l  cl2_construction2(a3),a2 ;2. CL
      ADDF.W  cl2_extension1_entry+cl2_ext1_BPL1DAT,a2
    ENDC
    move.l  cl2_display(a3),a4 ;3. CL
    ADDF.W  cl2_extension1_entry+cl2_ext1_BPL1DAT,a4
    moveq   #bf_lamellas_number-1,d7 ;Anzahl der Lamellen
blind_fader_in_loop1
    move.w  d2,d1            ;Startwert 
    moveq   #bf_lamella_height-1,d6 ;Höhe der Lamelle
blind_fader_in_loop2
    move.w  (a0,d1.w*2),d0   ;Registeradresse aus Tabelle lesen
    IFNE cl2_size1
      move.w  d0,(a1)        ;Adresse in 1. CL schreiben
      add.l   d4,a1          ;nächste Zeile in 1. CL
    ENDC
    IFNE cl2_size2
      move.w  d0,(a2)        ;Adresse in 2. CL schreiben
      add.l   d4,a2          ;nächste Zeile in 2. CL
    ENDC
    move.w  d0,(a4)          ;Adresse in 3. CL schreiben
    addq.w  #bf_step1,d1     ;nächster Eintrag in Tabelle
    add.l   d4,a4            ;nächste Zeile in 3. CL
    cmp.w   d3,d1            ;Ende erreicht ?
    blt.s   bfi_no_restart_register_table1
    sub.w   d3,d1            ;Neustart
bfi_no_restart_register_table1
    dbf     d6,blind_fader_in_loop2
    add.w   d5,d2            ;Startwert erhöhen
    cmp.w   d3,d2            ;Ende erreicht ?
    blt.s   bfi_no_restart_register_table2
    sub.w   d3,d2            ;Neustart
bfi_no_restart_register_table2
    dbf     d7,blind_fader_in_loop1
    move.l  (a7)+,a4
no_blind_fader_in
    rts
  
; ** Blind-Fader-Out **
    CNOP 0,4
blind_fader_out
    tst.w   bfo_active(a3)   ;Blind-Fader-Out an ?
    bne.s   no_blind_fader_out ;Nein -> verzweige
    move.l  a4,-(a7)
    move.w  bf_registers_table_start(a3),d2 ;Startwert der Tabelle 
    move.w  d2,d0            
    subq.w  #bf_speed,d0     ;Startwert der Tabelle verringern
    bpl.s   bfo_save_registers_table_start ;Wenn positiv -> verzweige
    moveq   #FALSE,d1
    move.w  d1,bfo_active(a3) ;Blind-Fader-Out aus
bfo_save_registers_table_start
    move.w  d0,bf_registers_table_start(a3) 
    MOVEF.W bf_registers_table_length,d3
    MOVEF.W cl2_extension1_size,d4
    moveq   #bf_step2,d5
    lea     bf_registers_table(pc),a0 ;Tabelle mit Registeradressen
    IFNE cl2_size1
      move.l  cl2_construction1(a3),a1 ;1. CL
      ADDF.W  cl2_extension1_entry+cl2_ext1_BPL1DAT,a1
    ENDC
    IFNE cl2_size2
      move.l  cl2_construction2(a3),a2 ;2. CL
      ADDF.W  cl2_extension1_entry+cl2_ext1_BPL1DAT,a2
    ENDC
    move.l  cl2_display(a3),a4 ;3. CL
    ADDF.W  cl2_extension1_entry+cl2_ext1_BPL1DAT,a4
    moveq   #bf_lamellas_number-1,d7 ;Anzahl der Lamellen
blind_fader_out_loop1
    move.w  d2,d1            ;Startwert 
    moveq   #bf_lamella_height-1,d6 ;Höhe der Lamelle
blind_fader_out_loop2
    move.w  (a0,d1.w*2),d0   ;Registeradresse aus Tabelle lesen
    IFNE cl2_size1
      move.w  d0,(a1)        ;Adresse in 1. CL schreiben
      add.l   d4,a1          ;nächste Zeile in 1. CL
    ENDC
    IFNE cl2_size2
      move.w  d0,(a2)        ;Adresse in 2. CL schreiben
      add.l   d4,a2          ;nächste Zeile in 2. CL
    ENDC
    move.w  d0,(a4)          ;Adresse in 3. CL schreiben
    addq.w  #bf_step1,d1     ;nächster Eintrag in Tabelle
    add.l   d4,a4            ;nächste Zeile in 3. CL
    cmp.w   d3,d1            ;Ende erreicht ?
    blt.s   bfo_no_restart_register_table1
    sub.w   d3,d1            ;Neustart
bfo_no_restart_register_table1
    dbf     d6,blind_fader_out_loop2
    add.w   d5,d2            ;Startwert erhöhen
    cmp.w   d3,d2            ;Ende erreicht ?
    blt.s   bfo_no_restart_register_table2
    sub.w   d3,d2            ;Neustart
bfo_no_restart_register_table2
    dbf     d7,blind_fader_out_loop1
    move.l  (a7)+,a4
no_blind_fader_out
    rts
  ENDC


  CNOP 0,4
mouse_handler
  btst    #CIAB_GAMEPORT0,CIAPRA(a4) ;Linke Maustaste gedrückt ?
  beq.s   mh_quit            ;Ja -> verzweige
  rts
  CNOP 0,4
mh_quit
  move.w  #FALSE,pt_effects_handler_active(a3) ;FX-Abfrage aus
  moveq   #0,d0
  move.w  d0,pt_music_fader_active(a3) ;Musik ausfaden
  move.w  d0,bfo_active(a3)  ;Blind-Fader-Out an
  rts


  INCLUDE "int-autovectors-handlers.i"

; ** CIA-B timer A interrupt server **
  IFEQ pt_ciatiming_enabled
  CNOP 0,4
ciab_ta_int_server
  ENDC

; ** Vertical blank interrupt server **
  IFNE pt_ciatiming_enabled
    CNOP 0,4
VERTB_int_server
  ENDC

  IFEQ pt_music_fader_enabled
    bsr.s   pt_music_fader
    bra.s   pt_PlayMusic

; ** Musik ausblenden **
    PT_FADE_OUT_VOLUME fx_active
    CNOP 0,4
  ENDC

; ** PT-replay routine **
  IFD PROTRACKER_VERSION_2.3A 
    PT2_REPLAY pt_effects_handler
  ENDC
  IFD PROTRACKER_VERSION_3.0B
    PT3_REPLAY pt_effects_handler
  ENDC

;--> 8xy "Not used/custom" <--
  CNOP 0,4
pt_effects_handler
  tst.w   pt_effects_handler_active(a3) ;Fx-Handler an?
  bne.s   pt_no_trigger_fx   ;Nein -> verzweige
  move.b  n_cmdlo(a2),d0     ;Command data x = Effekt y = TRUE/FALSE
  cmp.w   #$10,d0
  beq.s   pt_start_blind_fader_in
  cmp.b   #$20,d0
  beq.s   pt_start_scrolltext
pt_no_trigger_fx
  rts
  CNOP 0,4
pt_start_blind_fader_in
  clr.w   bfi_active(a3)     ;Blind-Fader-In an
  rts
  CNOP 0,4
pt_start_scrolltext
  clr.w   vst_enabled(a3)    ;Vert-Scrolltext an
  rts

; ** CIA-B Timer B interrupt server **
  CNOP 0,4
ciab_tb_int_server
  PT_TIMER_INTERRUPT_SERVER

; ** Level-6-Interrupt-Server **
  CNOP 0,4
EXTER_int_server
  rts

; ** Level-7-Interrupt-Server **
  CNOP 0,4
NMI_int_server
  rts


  INCLUDE "help-routines.i"


  INCLUDE "sys-structures.i"


  CNOP 0,4
pf1_color_table
  INCLUDE "Daten:Asm-Sources.AGA/projects/NoBitplanes/colortables/vcs3111_color-gradient.ct"

spr_pointers_construction
  DS.L spr_number

spr_pointers_display
  DS.L spr_number

sine_table
  INCLUDE "sine-table-256x32.i"

; **** PT-Replay ****
; ** Tables for effect commands **
; ** "Invert Loop" **
  INCLUDE "music-tracker/pt-invert-table.i"

; ** "Vibrato/Tremolo" **
  INCLUDE "music-tracker/pt-vibrato-tremolo-table.i"

; ** "Arpeggio/Tone Portamento" **
  IFD PROTRACKER_VERSION_2.3A 
    INCLUDE "music-tracker/pt2-period-table.i"
  ENDC
  IFD PROTRACKER_VERSION_3.0B
    INCLUDE "music-tracker/pt3-period-table.i"
  ENDC

; ** Temporary channel structures **
  INCLUDE "music-tracker/pt-temp-channel-data-tables.i"

; ** Pointers to samples **
  INCLUDE "music-tracker/pt-sample-starts-table.i"

; ** Pointers to priod tables for different tuning **
  INCLUDE "music-tracker/pt-finetune-starts-table.i"

; **** Volume-Meter ****
; Tabelle mit Ausschlägen und Y-Winkeln der einzelnen Kanäle **

  CNOP 0,2
vm_audio_channel1_info
  DS.B vm_audchaninfo_size

vm_audio_channel2_info
  DS.B vm_audchaninfo_size

vm_audio_channel3_info
  DS.B vm_audchaninfo_size

vm_audio_channel4_info
  DS.B vm_audchaninfo_size

; **** Vertical-Scrolltext ****
; ** ASCII-Buchstaben **
vst_ascii
  DC.B "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?-'():\/#* "
vst_ascii_end
  EVEN

; ** Offsets der einzelnen Chars **
  CNOP 0,2
vst_characters_offsets
  DS.W vst_ascii_end-vst_ascii
  
; ** Y-Koordinaten der einzelnen BOBs der Laufschrift **
vst_characters_y_positions
  DS.W vst_text_characters_number

; ** Tabelle für Char-Image-Adressen **
  CNOP 0,4
vst_characters_image_pointers
  DS.L vst_text_characters_number

; **** Blind-Fader ****
  IFEQ open_border_enabled
; ** Tabelle mit Registeradressen **
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

; **** Vertical-Scrolltext ****
; ** Text für Laufschrift **
vst_text
  REPT vst_text_characters_number/((vst_origin_character_y_size+1)/vst_text_character_y_size)
    DC.B " "
  ENDR
  DC.B "RESISTANCE IS BACK WITH A NEW INTRO CALLED   NO BITPLANES                 "

  DC.B "GREETINGS FLY TO   "
  DC.B "#DESIRE#   "
  DC.B "#EPHIDRENA#   "
  DC.B "#FOCUS DESIGN#   "
  DC.B "#GHOSTOWN#   "
  DC.B "#NAH-KOLOR#   "
  DC.B "#PLANET JAZZ#   "
  DC.B "#SOFTWARE FAILURE#   "
  DC.B "#TEK#   "
  DC.B "#WANTED TEAM#                 "

  DC.B "THE CREDITS FOR THIS INTRO   "
  DC.B "CODING BY DISSIDENT   "
  DC.B "GRAPHICS BY NN   "
  DC.B "MUSIC BY MA2E                 "

  DC.B "SEE YOU IN ANOTHER PRODUCTION..."
  REPT vst_text_characters_number/((vst_origin_character_y_size+1)/vst_text_character_y_size)
    DC.B " "
  ENDR
  DC.B FALSE
  EVEN


  DC.B "$VER: RSE-NoBitplanes 1.1 beta (2.6.24)",0
  EVEN


; ** Audiodaten nachladen **

; **** PT-Replay ****
  IFEQ pt_split_module_enabled
pt_auddata SECTION pt_audio,DATA
    INCBIN "Daten:Asm-Sources.AGA/projects/NoBitplanes/modules/MOD.end_of_2021.song"
pt_audsmps SECTION pt_audio2,DATA_C
    INCBIN "Daten:Asm-Sources.AGA/projects/NoBitplanes/modules/MOD.end_of_2021.smps"
  ELSE
pt_auddata SECTION pt_audio,DATA_C
    INCBIN "Daten:Asm-Sources.AGA/projects/NoBitplanes/modules/mod.end_of_2021"
  ENDC


; ** Grafikdaten nachladen **

; **** Logo ****
lg_image_data SECTION lg_gfx,DATA
  INCBIN "Daten:Asm-Sources.AGA/projects/NoBitplanes/graphics/32x256x16-Resistance.rawblit"

; **** Vertical-Scrolltext ****
vst_image_data SECTION vst_gfx,DATA_C
  INCBIN "Daten:Asm-Sources.AGA/projects/NoBitplanes/fonts/16x15x2-Font.rawblit"
  DS.B vst_image_plane_width*vst_image_depth ;Leerzeile

  END
