#!/bin/bash

# Blood Pressure Analyzer Script
# Categories per AHA/ACC guidelines
#   NORMAL:    sys <120        AND dia <80
#   ELEVATED:  sys 120-129     AND dia <80
#   STAGE 1:   sys 130-139     OR  dia 80-89
#   STAGE 2:   sys >=140       OR  dia >=90
#   CRISIS:    sys >180 and/or dia >120

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
NC='\033[0m'

echo "Blood Pressure Analysis"
echo "======================="
read -r -p "Enter your SYSTOLIC pressure (top number): " systolic
read -r -p "Enter your DIASTOLIC pressure (bottom number): " diastolic

if ! [[ "$systolic" =~ ^[0-9]+$ ]] || ! [[ "$diastolic" =~ ^[0-9]+$ ]]; then
    echo "Please enter valid non-negative whole numbers."
    exit 1
fi

# AHA/ACC category logic
if (( systolic > 180 || diastolic > 120 )); then
    category="HYPERTENSIVE CRISIS - Seek emergency care immediately!"
    color=$PURPLE
    icon="🚨"
elif (( systolic >= 140 || diastolic >= 90 )); then
    category="Stage 2 Hypertension"
    color=$RED
    icon="🔴"
elif (( systolic >= 130 || diastolic >= 80 )); then
    category="Stage 1 Hypertension"
    color=$ORANGE
    icon="⚠️"
elif (( systolic >= 120 && systolic <= 129 && diastolic < 80 )); then
    category="Elevated"
    color=$YELLOW
    icon="↑"
elif (( systolic < 120 && diastolic < 80 )); then
    category="Normal"
    color=$GREEN
    icon="✓"
else
    category="Consult healthcare provider for interpretation"
    color=$BLUE
    icon="?"
fi

echo -e "\nBlood Pressure Reading: ${color}${systolic}/${diastolic} mmHg${NC}"
echo -e "Category: ${color}${icon} ${category}${NC}\n"

# Linear chart printer
print_chart() {
    local title=$1
    local value=$2
    local max=$3
    local width=$4
    local step=$5
    local color=$6

    local bar_length=$(( value * width / max ))
    (( bar_length > width )) && bar_length=$width
    (( bar_length < 0 )) && bar_length=0

    local tick_interval=$(( width * step / max ))
    (( tick_interval < 1 )) && tick_interval=1

    echo "$title"

    # Bar
    printf "  "
    for ((i=0; i<bar_length; i++)); do printf "${color}█${NC}"; done
    for ((i=bar_length; i<width; i++)); do printf " "; done
    printf "\n"

    # Ruler
    printf "  "
    for ((i=0; i<width; i++)); do
        if (( i % tick_interval == 0 )); then
            printf "|"
        else
            printf "-"
        fi
    done
    printf "|\n"

    # Labels
    printf "  "
    for ((v=0; v<=max; v+=step)); do
        printf "%-${tick_interval}s" "$v"
    done
    printf "\n"
}

print_chart "Blood Pressure Chart (Systolic; 0-200 mmHg)" "$systolic" 200 50 20 "$color"
echo -e "Systolic: ${color}${systolic} mmHg${NC} (${color}$((systolic * 100 / 200))%${NC} of 0-200 range)\n"

print_chart "Blood Pressure Chart (Diastolic; 0-120 mmHg)" "$diastolic" 120 60 20 "$color"
echo -e "Diastolic: ${color}${diastolic} mmHg${NC} (${color}$((diastolic * 100 / 120))%${NC} of 0-120 range)\n"

echo -e "${color}${icon} ${category}${NC}\n"

echo -e "Blood Pressure Categories (AHA Guidelines):"
echo -e "${GREEN}■${NC} Normal:        <120 AND <80"
echo -e "${YELLOW}■${NC} Elevated:      120-129 AND <80"
echo -e "${ORANGE}■${NC} Stage 1:       130-139 OR 80-89"
echo -e "${RED}■${NC} Stage 2:       >=140 OR >=90"
echo -e "${PURPLE}■${NC} Crisis:        >180 OR >120 (Emergency!)"

echo -e "\nRecommendations:"
case "$category" in
    "Normal")
        echo "✓ Keep up the good work!"
        echo "✓ Maintain healthy lifestyle"
        echo "✓ Regular check-ups recommended"
        ;;
    "Elevated")
        echo "↑ Lifestyle changes recommended:"
        echo "  • Reduce sodium intake"
        echo "  • Increase physical activity (150 min/week)"
        echo "  • Maintain healthy weight"
        echo "  • Limit alcohol consumption"
        echo "  • Recheck in 3-6 months"
        ;;
    "Stage 1 Hypertension")
        echo "⚠️ Consult healthcare provider within 1 month:"
        echo "  • Lifestyle modifications are essential"
        echo "  • Medication may be considered based on risk"
        echo "  • Monitor at home regularly"
        echo "  • Follow up in 1 month"
        ;;
    "Stage 2 Hypertension")
        echo "🔴 Seek medical attention within 2-4 weeks:"
        echo "  • Medication is typically recommended"
        echo "  • Immediate lifestyle changes required"
        echo "  • Regular monitoring essential"
        echo "  • Follow up with doctor promptly"
        ;;
    "HYPERTENSIVE CRISIS - Seek emergency care immediately!")
        echo "🚨 EMERGENCY - Call 911 or go to ER immediately!"
        echo "  • Do not wait"
        echo "  • Do not drive yourself"
        echo "  • Seek immediate medical attention"
        echo "  • This is life-threatening"
        ;;
    *)
        echo "• Consult healthcare provider"
        echo "• Discuss readings with your doctor"
        echo "• Regular monitoring recommended"
        ;;
esac

echo -e "\nNote: Single readings may not indicate chronic conditions."
echo "Multiple elevated readings over time require medical evaluation."
echo "Consult your healthcare provider for personalized targets."
