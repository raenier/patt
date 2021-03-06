/*Generate DTR Form*/
function generateDTRForm() {
    var sDate = "";
    var eDate = "";
    inputFields = ['#calDTRSDate','#calDTREDate'];
    formValidate = validateDateInput(inputFields);
    if (formValidate===true){
        var startDate = new Date($(inputFields[0]).val()); //YYYY-MM-DD
        var endDate = new Date($(inputFields[1]).val()); //YYYY-MM-DD
        var getDateArray = function(start, end) {
            var arr = new Array();
            var dt = new Date(start);
            var dayName = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
            var monthName = ["January","February","March","April","May","June","July","August","September","October","November","December"];
            while (dt <= end) {
                arr.push(dayName[dt.getDay()]+' '+monthName[dt.getMonth()]+' '+dt.getDate()+', '+dt.getFullYear());
                dt.setDate(dt.getDate() + 1);
            }
            return arr;
        }

        var dateArr = getDateArray(startDate, endDate);
        /*Clear table body before inserting new rows*/
        $('#tblAttendance tbody tr').remove();
        $('#tblOtherPay tbody tr').remove();
        for (var i = 0; i < dateArr.length; i++) {
            /*console.log(dateArr[i]);*/
            $('#tblAttendance tbody').append(
                '<tr>'+
                    '<td><input type="text" class="form-control" value="'+dateArr[i]+'" readonly></td>'+
                    '<td><input type="time" class="form-control"></td>'+
                    '<td><input type="time" class="form-control"></td>'+
                    '<td>'+
                        '<select class="form-control">'+
                            '<option>Regular Pay</option>'+
                            '<option>VL</option>'+
                            '<option>SL</option>'+
                            '<option>BL</option>'+
                            '<option>OB</option>'+
                            '<option>OT</option>'+
                            '<option>RD-OT</option>'+
                            '<option>HO-Pay</option>'+
                            '<option>Tardiness</option>'+
                            '<option>Absent</option>'+
                        '</select>'+
                    '</td>'+
                    '<td><input type="text" class="form-control" placeholder="0.00" readonly></td>'+
                    '<td><input type="text" class="form-control" placeholder="0.00" readonly></td>'+
                '</tr>'
            );
            $('#tblOtherPay tbody').append(
                '<tr>'+
                    '<td><input type="text" class="form-control" value="'+dateArr[i]+'" readonly></td>'+
                    '<td><input type="time" class="form-control"></td>'+
                    '<td><input type="time" class="form-control"></td>'+
                    '<td>'+
                        '<select class="form-control">'+
                            '<option>Regular Pay</option>'+
                            '<option>OFFSET</option>'+
                            '<option>HO-OT</option>'+
                            '<option>ND-OT</option>'+
                            '<option>MEAL</option>'+
                            '<option>TRANSPORTATION</option>'+
                        '</select>'+
                    '</td>'+
                    '<td><input type="text" class="form-control" placeholder="0.00" readonly></td>'+
                '</tr>'
            );
        }
    }
    else {
        if (formValidate == "inverse") {
            alert('Invalid date range. Please check if end date is not earlier than start date.');
        }
        else {
            alert('Fill in start and end dates.');
        }
    }
}

function validateDateInput(inputFields){
    var formValidate = true;
    var sDate = '';
    var eDate = '';
    $.each(inputFields, function(index, value){
        if ($(value).val() == "") {
            formValidate = "empty";
        }
    });
    if (formValidate != 'empty') {
        sDate = new Date($(inputFields[0]).val());
        eDate = new Date($(inputFields[1]).val());
        if (eDate < sDate) {
            formValidate = "inverse";
        }
    }
    return formValidate;
}

function getmonthInput() {
  val = document.getElementById("acinput").value;
  document.getElementById("inputa").value = val;
  document.getElementById("inputb").value = val;
  document.getElementById("inpute").value = val;
  document.getElementById("inputf").value = val;
  document.getElementById("inputg").value = val;
}

function validateValues(from, to) {
  fromval = new Date(document.getElementById(from).value);
  toval = new Date(document.getElementById(to).value);
  if (fromval > toval) {
    alert("Invalid Input-: From: should be earlier than To:");
    return false;
  } else {
    return true;
  }
}
