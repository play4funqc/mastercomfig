#!/bin/bash
# Run script within the directory
BINDIR=$(dirname "$(readlink -fn "$0")")
cd "$BINDIR"

# Delete old VPKs and folders
rm *.vpk -f
rm */ -rf

# Create presets
declare -a presets=("stripped" "maxperformance" "comp" "compquality" "default" "midquality" "maxquality")

for P in "${presets[@]}"; do
    mkdir -p mastercomfig-"${P}"/cfg/presets
    cp -f ../../config/mastercomfig/cfg/presets/"${P}".cfg mastercomfig-"${P}"/cfg/presets/"${P}".cfg
    touch mastercomfig-"${P}"/cfg/autoexec.cfg
    echo -e "exec comfig\r\nexec presets/${P}\r\nexec addons/badcpu\r\nexec addons/badgpu\r\nexec addons/ssd\r\nexec addons/transparent_viewmodels\r\nexec custom\r\n" > mastercomfig-"${P}"/cfg/autoexec.cfg
done

# Create custom preset
mkdir -p mastercomfig-custom/cfg
touch mastercomfig-custom/cfg/autoexec.cfg
echo -e "exec comfig\r\nexec addons/badcpu\r\nexec addons/badgpu\r\nexec addons/ssd\r\nexec addons/transparent_viewmodels\r\nexec custom\r\n" > mastercomfig-custom/cfg/autoexec.cfg

# Fill folders with common files
for D in *; do
    if [ -d "${D}" ]; then
        cp -f ../../config/mastercomfig/cfg/*.cfg "${D}"/cfg/
        cp -f ../../config/mastercomfig/dxsupport_override.cfg "${D}"/dxsupport_override.cfg
        cp -f ../../config/mastercomfig/glbaseshaders.cfg "${D}"/glbaseshaders.cfg
        cp -f ../../config/mastercomfig/texture_preload_list.txt "${D}"/texture_preload_list.txt
        mkdir -p "${D}"/scripts
        cp -f ../../config/mastercomfig/scripts/client_precache.txt "${D}"/scripts/client_precache.txt
        cp -f ../../config/mastercomfig/scripts/extra_models.txt "${D}"/scripts/extra_models.txt
    fi
done

declare -a overriden_presets=("maxperformance" "stripped" "maxquality")
declare -a override_combos=("01-mastercomfig_maxperformance 01-mastercomfig_no_soundscapes 01-mastercomfig_no_pyroland" "01-mastercomfig_maxperformance 01-mastercomfig_no_footsteps 01-mastercomfig_no_soundscapes 01-mastercomfig_no_pyroland" "01-mastercomfig_maxquality")

# Preset specific overrides
for ((i=0; i<${#overriden_presets[*]}; i++));
do
    folder="mastercomfig-${overriden_presets[i]}/"
    for override in ${override_combos[i]}
    do
        cp -rf "../../config/$override/"* $folder
    done
done

# Cheap water override
declare -a game_overrides_water=("r_cheapwaterstart" "r_cheapwaterend")
declare -a game_overrides_water_values=("0.1 1" "400 1000" "3000 5000")
declare -a game_overrides_water_preset_keys=(0 1 1 1 1 1 2)

# Detail controller override
declare -a game_overrides_detail=("cl_detaildist" "cl_detailfade")
declare -a game_overrides_detail_values=("900 0" "3000 100")
declare -a game_overrides_detail_preset_keys=(-1 -1 -1 -1 -1 0 1)

for P in "${presets[@]}"; do
  preset_folder=mastercomfig-"${P}"/cfg
  touch "${preset_folder}"/game_overrides.cfg
done

for ((i=0; i<${#presets[*]}; i++));
do
    file=mastercomfig-${presets[i]}/cfg/game_overrides.cfg
    touch "${file}"
    value_combo_water=(${game_overrides_water_values[${game_overrides_water_preset_keys[i]}]})
    for ((j=0; j<${#value_combo_water[*]}; j++))
    do
      echo -e "${game_overrides_water[j]} ${value_combo_water[j]}" >> "${file}"
    done
    index_value_combo_detail=${game_overrides_detail_preset_keys[i]}
    if [ $index_value_combo_detail -ne -1 ]; then
      value_combo_detail=(${game_overrides_detail_values[${index_value_combo_detail}]})
      for ((j=0; j<${#value_combo_detail[*]}; j++))
      do
        echo -e "${game_overrides_detail[j]} ${value_combo_detail[j]}" >> "${file}"
      done
    fi
    echo -e "" >> "${file}"
done

# Package into VPK
for D in *; do
    if [ -d "${D}" ]; then
        vpk "${D}"
    fi
done

printf "\n"
