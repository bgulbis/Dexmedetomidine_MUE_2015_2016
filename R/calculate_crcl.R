# calculate_crcl.R

#' Caculate the creatinine clearance
#'
#' \code{calculate_crcl} calculates the creatinine clearance using the
#' Cockcroft-Gault equation
#'
#' This function calculates the creatinine clearance for a patient based on the
#' Cockcroft-Gault equation: CrCl[mL/min] = Sex * ((140 - Age[yr]) / Serum
#' Creatinine[mg/dL]) * (Lean Body Weight[kg] / 72); where Sex = 1 for Males and Sex =
#' 0.85 for Females.
#'
#'
#' @param age A numeric with the patient's age
#' @param sex A character indicating patient's gender, as "Male" or "Female"
#' @param scr A numeric with the serum creatinine, in mg/dL
#' @param weight A numeric with the patient's actual body weight, in kg
#' @param height A numeric with the patient's height, in cm
#'
#' @return A numeric, creatinine clearance in mL/min
#'
#' @references Cockcroft DW, Gault MH. Prediction of creatinine clearance from serum creatinine. Nephron. 1976;16(1):31-41
#'
#' @export
calculate_crcl <- function(age, sex, scr, weight, height) {
    lbw <- calculate_leanbw(sex, height)

    if (weight < lbw) {
        wt <- weight
    } else {
        wt <- lbw
    }

    if (sex == "Female") {
        gender = 0.85
    } else {
        gender = 1
    }

    gender * ((140 - age) / scr) * (wt / 72)
}


#' Calculate the Lean Body Weight
#'
#' \code{calculate_leanbw} calculates the ideal body weight in kg
#'
#' This function takes a patient's height and based on their gender returns the
#' patient's lean body weight in kg. For males, the equation is: LBW[kg] = (0.73
#' * Height[cm]) - 59.42; for females: LBW[kg] = (0.65 * Height[cm]) - 50.74.
#'
#' @param sex A character indicating patient's gender, as "Male" or "Female"
#' @param height A numeric with the patient's height, in cm
#'
#' @return A numeric, ideal body weight, in kg
#'
#' @references Burton ME, Chow MS, Platt DR, et. al. Accuracy of Bayesian and Sawchuk-Zaske dosing methods for gentamicin. Clin Pharm. 1986 Feb;5(2):143-9
#'
calculate_leanbw <- function(sex, height) {
    if (sex == "Male") {
        (0.73 * height) - 59.42
    } else {
        (0.65 * height) - 50.74
    }
}
