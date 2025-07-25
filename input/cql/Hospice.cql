library Hospice version '6.18.000'

using QICore version '6.0.0'

include FHIRHelpers version '4.4.000' called FHIRHelpers
include QICoreCommon version '4.0.000' called QICoreCommon
include Status version '1.15.000' called Status

codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMEDCT": 'http://snomed.info/sct'

valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'
valueset "Hospice Care Ambulatory": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1584'
valueset "Hospice Encounter": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1003'
valueset "Hospice Diagnosis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1165'

code "Discharge to healthcare facility for hospice care (procedure)": '428371000124100' from "SNOMEDCT" display 'Discharge to healthcare facility for hospice care (procedure)'
code "Discharge to home for hospice care (procedure)": '428361000124107' from "SNOMEDCT" display 'Discharge to home for hospice care (procedure)'
code "Hospice care [Minimum Data Set]": '45755-6' from "LOINC" display 'Hospice care [Minimum Data Set]'
code "Yes (qualifier value)": '373066001' from "SNOMEDCT" display 'Yes (qualifier value)'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Has Hospice Services":
  exists ((([Encounter: "Encounter Inpatient"]).isEncounterPerformed()) InpatientEncounter
      where (InpatientEncounter.hospitalization.dischargeDisposition ~ "Discharge to home for hospice care (procedure)"
          or InpatientEncounter.hospitalization.dischargeDisposition ~ "Discharge to healthcare facility for hospice care (procedure)"
      )
        and InpatientEncounter.period ends during day of "Measurement Period"
  )
    or exists ((([Encounter: "Hospice Encounter"]).isEncounterPerformed()) HospiceEncounter
        where HospiceEncounter.period overlaps day of "Measurement Period"
    )
    or exists ((([ObservationScreeningAssessment: "Hospice care [Minimum Data Set]"]).isAssessmentPerformed()) HospiceAssessment
        where HospiceAssessment.value ~ "Yes (qualifier value)"
          and HospiceAssessment.effective.toInterval() overlaps day of "Measurement Period"
    )
    or exists ((([ServiceRequest: "Hospice Care Ambulatory"]).isInterventionOrder()) HospiceOrder
        where HospiceOrder.authoredOn during day of "Measurement Period"
    )
    or exists ((([Procedure: "Hospice Care Ambulatory"]).isInterventionPerformed()) HospicePerformed
        where HospicePerformed.performed.toInterval() overlaps day of "Measurement Period"
    )
    or exists ((([ConditionProblemsHealthConcerns: "Hospice Diagnosis"]
        union [ConditionEncounterDiagnosis: "Hospice Diagnosis"]).verified()) HospiceCareDiagnosis
        where HospiceCareDiagnosis.prevalenceInterval() overlaps day of "Measurement Period"
    )