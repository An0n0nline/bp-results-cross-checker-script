#!/bin/bash

# Blood Pressure Analyzer Script
# Categories per AHA/ACC guidelines (heart.org/bplevels)
#
#   NORMAL:    sys <120        AND dia <80
#   ELEVATED:  sys 120-129     AND dia <80
#   STAGE 1:   sys 130-139     OR  dia 80-89   <- dia==80 lands here, not Elevated
#   STAGE 2:   sys >=140       OR  dia >=90
#   CRISIS:    sys >180 and/or dia >120

NORMAL_SYS_MAX=120
NORMAL_DIA_MAX=80
ELEVATED_SYS_MIN=120
ELEVATED_SYS_MAX=129
ELEVATED_DIA_MAX=80
HYPERTENSION_STAGE1_SYS_MIN=130
HYPERTENSION_STAGE1_SYS_MAX=139
HYPERTENSION_STAGE1_DIA_MIN=80
HYPERTENSION_STAGE1_DIA_MAX=89
HYPERTENSION_STAGE2_SYS_MIN=140
HYPERTENSION_STAGE2_DIA_MIN=90
HYPERTENSION_CRISIS_SYS=180
HYPERTENSION_CRISIS_DIA=120

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Get user input
echo "Blood Pressure Analysis"
echo "======================="
read -p "Enter your SYSTOLIC pressure (top number): " systolic
read -p "Enter your DIASTOLIC pressure (bottom number): " diastolic

# Validate input
if ! [[ "$systolic" =~ ^[0-9]+$ ]] || ! [[ "$diastolic" =~ ^[0-9]+$ ]]; then
    echo "Please enter valid numbers."
    exit 1
fi

# Determine BP category — check Elevated before Stage 1, both before Stage 2/Crisis
if [ "$systolic" -ge "$HYPERTENSION_CRISIS_SYS" ] || [ "$diastolic" -ge "$HYPERTENSION_CRISIS_DIA" ]; then
    category="HYPERTENSIVE CRISIS - Seek emergency care immediately!"
    color=$PURPLE
    icon="🚨"
elif [ "$systolic" -ge "$HYPERTENSION_STAGE2_SYS_MIN" ] || [ "$diastolic" -ge "$HYPERTENSION_STAGE2_DIA_MIN" ]; then
    category="Stage 2 Hypertension"
    color=$RED
    icon="🔴"
elif [ "$systolic" -ge "$ELEVATED_SYS_MIN" ] && [ "$systolic" -le "$ELEVATED_SYS_MAX" ] && [ "$diastolic" -lt "$ELEVATED_DIA_MAX" ]; then
    category="Elevated"
    color=$YELLOW
    icon="↑"
elif [ "$systolic" -ge "$HYPERTENSION_STAGE1_SYS_MIN" ] || [ "$diastolic" -ge "$HYPERTENSION_STAGE1_DIA_MIN" ]; then
    category="Stage 1 Hypertension"
    color=$ORANGE
    icon="⚠️"
elif [ "$systolic" -le "$NORMAL_SYS_MAX" ] && [ "$diastolic" -le "$NORMAL_DIA_MAX" ]; then
    category="Normal"
    color=$GREEN
    icon="✓"
else
    # Kept as a safety net; every real combination is caught above.
    category="Consult healthcare provider for interpretation"
    color=$BLUE
    icon="?"
fi

# Print analysis
echo -e "\nBlood Pressure Reading: ${color}${systolic}/${diastolic} mmHg${NC}"
echo -e "Category: ${color}${icon} ${category}${NC}\n"

# Create BP chart
echo "Blood Pressure Chart (Systolic):"
echo "  0    60   90   120  140  160  180  200"
echo "  |-----|-----|-----|-----|-----|-----|"

max_chart_value=200
bar_length=$(( systolic * 50 / max_chart_value ))
[ "$bar_length" -gt 50 ] && bar_length=50
[ "$bar_length" -lt 0 ] && bar_length=0

printf "  "
for ((i=1; i<=$bar_length; i++)); do
    printf "${color}█${NC}"
done
if [ $bar_length -lt 50 ]; then
    for ((i=$bar_length; i<50; i++)); do
        printf " "
    done
fi
printf "\n"

echo "  |-----|-----|-----|-----|-----|-----|"
echo "  0    60   90   120  140  160  180  200"
echo -e "\nSystolic: ${color}${systolic} mmHg${NC} (${color}$((systolic * 100 / 200))%${NC} of range)"

echo -e "\nBlood Pressure Chart (Diastolic):"
echo "  0    40   60   80   90   100  120"
echo "  |-----|-----|-----|-----|-----|"

max_chart_value_dia=120
bar_length_dia=$(( diastolic * 50 / max_chart_value_dia ))
[ "$bar_length_dia" -gt 50 ] && bar_length_dia=50
[ "$bar_length_dia" -lt 0 ] && bar_length_dia=0

printf "  "
for ((i=1; i<=$bar_length_dia; i++)); do
    printf "${color}█${NC}"
done
if [ $bar_length_dia -lt 50 ]; then
    for ((i=$bar_length_dia; i<50; i++)); do
        printf " "
    done
fi
printf "\n"

echo "  |-----|-----|-----|-----|-----|"
echo "  0    40   60   80   90   100  120"
echo -e "\nDiastolic: ${color}${diastolic} mmHg${NC} (${color}$((diastolic * 100 / 120))%${NC} of range)"

echo -e "\n${color}${icon} ${category}${NC}"

echo -e "\nBlood Pressure Categories (AHA Guidelines):"
echo -e "${GREEN}■${NC} Normal:        <120 AND <80"
echo -e "${YELLOW}■${NC} Elevated:      120-129 AND <80"
echo -e "${ORANGE}■${NC} Stage 1:       130-139 OR 80-89"
echo -e "${RED}■${NC} Stage 2:       ≥140 OR ≥90"
echo -e "${PURPLE}■${NC} Crisis:        ≥180 OR ≥120 (Emergency!)"

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
