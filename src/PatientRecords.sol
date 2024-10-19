// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract PatientRecords {

    // Structs for patient and medical history
    struct Patient {
        bytes32 uuid;
        string name;
        string phone;
        uint age;
        MedicalHistory medicalHistory;
    }

    struct MedicalHistory {
        Test[] tests;
        VitalSign[] vitalSigns;
        Medication[] medications;
        Allergy[] allergies;
        Surgery[] surgeries;
        FamilyHistory[] familyHistories;
    }

    struct Test {
        string testName;
        string result;
        uint timestamp;
    }

    struct VitalSign {
        string vitalName;
        string value;
        uint timestamp;
    }

    struct Medication {
        string illness;
        string medicationName;
        string dosage;
        uint startDate;
        uint endDate;
    }

    struct Allergy {
        string allergen;
        string reaction;
        uint timestamp;
    }

    struct Surgery {
        string surgeryType;
        string outcome;
        uint date;
    }

    struct FamilyHistory {
        string relation;
        string condition;
        string details;
    }

    // Mappings for storing patient records
    mapping(bytes32 => Patient) private patientsByUUID;
    mapping(string => bytes32) private patientPhoneToUUID;
    bytes32[] private patientList;

    /*----------------------- Patient Management --------------------------*/

    function createPatient(bytes32 _uuid, string memory _name, string memory _phone, uint _age) public {
        require(patientPhoneToUUID[_phone] == 0, "Patient already exists");

        Patient storage patient = patientsByUUID[_uuid];
        patient.uuid = _uuid;
        patient.name = _name;
        patient.phone = _phone;
        patient.age = _age;

        patientPhoneToUUID[_phone] = _uuid;
        patientList.push(_uuid);
    }

    function getPatientByUUID(bytes32 _uuid) public view returns (Patient memory) {
        return patientsByUUID[_uuid]; // No proper check for patient existence
    }

    // Fetch a patient by phone number
    function getPatientByPhone(string memory _phone) public view returns (Patient memory) {
        bytes32 uuid = patientPhoneToUUID[_phone];
        return getPatientByUUID(uuid);
    }

    // Return a list of all patients
    function listAllPatients() public view returns (Patient[] memory) {
        Patient[] memory allPatients = new Patient[](patientList.length);
        for (uint i = 0; i < patientList.length; i++) {
            allPatients[i] = patientsByUUID[patientList[i]]; // Could cause gas issues with large data
        }
        return allPatients;
    }

    /*----------------------- Medical Records Management --------------------------*/

    function addTestResult(bytes32 _uuid, string memory _testName, string memory _result) public {
        require(patientsByUUID[_uuid].uuid != 0, "Patient not found");
        Test memory newTest = Test(_testName, _result, block.timestamp); // Vulnerability 6: block.timestamp manipulation
        patientsByUUID[_uuid].medicalHistory.tests.push(newTest);
    }

    function addVitalSign(bytes32 _uuid, string memory _vitalName, string memory _value) public {
        require(patientsByUUID[_uuid].uuid != 0, "Patient not found");
        VitalSign memory newVitalSign = VitalSign(_vitalName, _value, block.timestamp);
        patientsByUUID[_uuid].medicalHistory.vitalSigns.push(newVitalSign);
    }

    function addMedication(bytes32 _uuid, string memory _illness, string memory _medicationName, string memory _dosage, uint _startDate, uint _endDate) public {
        require(patientsByUUID[_uuid].uuid != 0, "Patient not found");
        Medication memory newMedication = Medication(_illness, _medicationName, _dosage, _startDate, _endDate);
        patientsByUUID[_uuid].medicalHistory.medications.push(newMedication);
    }

    function addAllergy(bytes32 _uuid, string memory _allergen, string memory _reaction) public {
        require(patientsByUUID[_uuid].uuid != 0, "Patient not found");
        Allergy memory newAllergy = Allergy(_allergen, _reaction, block.timestamp);
        patientsByUUID[_uuid].medicalHistory.allergies.push(newAllergy);
    }

    function addSurgery(bytes32 _uuid, string memory _surgeryType, string memory _outcome, uint _date) public {
        require(patientsByUUID[_uuid].uuid != 0, "Patient not found");
        Surgery memory newSurgery = Surgery(_surgeryType, _outcome, _date);
        patientsByUUID[_uuid].medicalHistory.surgeries.push(newSurgery);
    }

    function addFamilyHistory(bytes32 _uuid, string memory _relation, string memory _condition, string memory _details) public {
        require(patientsByUUID[_uuid].uuid != 0, "Patient not found");
        FamilyHistory memory newFamilyHistory = FamilyHistory(_relation, _condition, _details);
        patientsByUUID[_uuid].medicalHistory.familyHistories.push(newFamilyHistory);
    }

    function getPatientMedicalHistory(bytes32 _uuid) public view returns (MedicalHistory memory) {
        return patientsByUUID[_uuid].medicalHistory; // Vulnerability 7: No existence check
    }
}
