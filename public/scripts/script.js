$(document).ready(function() {
    $(document).on('change', '.btn-file :file', function() {
        var input = $(this),
            numFiles = input.get(0).files ? input.get(0).files.length : 1,
            label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
            input.trigger('fileselect', [numFiles, label]);
    });
    $('.btn-file :file').on('fileselect', function(event, numFiles, label) {
        var input = $(this).parents('.input-group').find(':text'),
            log = numFiles > 1 ? numFiles + ' files selected' : label;
        if( input.length ) {
            input.val(log);
        } else {
            if( log ) alert(log);
        }
    });
    $('#summernote').summernote({
        height: 300,
        onBlur: function() {
            $("#eventDescription").val($("#summernote").code());
        },
        onImageUpload: function(files, editor, welEditable) {
            sendFile(files[0],$("#summernote"),welEditable);
        }
    });
    $("#eventDescription").val($("#summernote").code());
    $('#driverBioEditor').summernote({
        height: 300,
        onBlur: function() {
            $("#driverBio").val($("#driverBioEditor").code());
        },
        onImageUpload: function(files, editor, welEditable) {
            sendFile(files[0],$("#driverBioEditor"),welEditable);
        }
    });
    $("#driverBio").val($("#driverBioEditor").code());
    $('#vehicleDescriptionEditor').summernote({
        height: 300,
        onBlur: function() {
            $("#vehicleDescription").val($("#vehicleDescriptionEditor").code());
        },
        onImageUpload: function(files, editor, welEditable) {
            sendFile(files[0],$("#vehicleDescriptionEditor"),welEditable);
        }
    });
    $("#vehicleDescription").val($("#vehicleDescriptionEditor").code());
    $("#partnerLinkDiv").hide();
    $("#eventType").change(toggleEventType);
    toggleEventType();
    $("#addParticipantForm").validator().on('submit', function(e) {
        if (e.isDefaultPrevented()) {
        } else {
            e.preventDefault();
            $.ajax({
                data: $("#addParticipantForm").serialize(),
                type: "POST",
                url: "/profile/participant",
                cache: false,
                processData: false,
                success: function(hash) {
                    $("#addParticipant").modal('hide');
                    $("#addParticipantForm").trigger('reset');
                    $("#participantsTable").bootstrapTable('refresh');
                }
            });

        }
    });
    $("#participantsTable").on('dbl-click-row.bs.table', function(e, row, element) {
        $('#event_participant_id').val(row.event_participant_id).change();
        $('#addFirstName').val(row.first_name).change();
        $('#addLastName').val(row.last_name).change();
        $('#add_emergency_contact_name').val(row.emergency_contact_name).change();
        $('#add_emergency_contact_phone').val(row.emergency_contact_phone).change();
        $('#add_medical_info').val(row.medical_info).change();
        $("#addParticipant").modal('show');
    });
    $("#registerEventForm").on('submit', function(e) {
        var v = $("#participantsTable").bootstrapTable('getSelections').map(function(a) { return a.event_participant_id; }).join(',');
        $("#participants").val(v).change();
    });
    $("#newsTable").on('dbl-click-row.bs.table', function(e, row, element) {
        window.location='/admin/news/'+row.news_id+'/edit';
    });
});

function toggleEventType() {
    var val = $("#eventType").val();
    if (val == "normal") {
        $("#dateFields").show();
        $("#partnerLinkDiv").hide();
    } else if (val == "tentative") {
        $("#dateFields").hide();
        $("#partnerLinkDiv").hide();
    } else if (val == "partner") {
        $("#dateFields").show();
        $("#partnerLinkDiv").show();
    }
}

function addParticipant() {
}
function sendFile(file,editor,welEditable) {
    data = new FormData();
    data.append("file", file);
    $.ajax({
        data: data,
        type: "POST",
        url: "/image",
        cache: false,
        contentType: false,
        processData: false,
        success: function(hash) {
            var url = "/image/"+hash;
            editor.summernote("insertImage", url, hash);
        }
    });
}

function formatUserEmail(value, row, index) {
    return '<a href="/admin/users/'+row.user_id+'">'+value+"</a>";
}

function formatNewsDelete(value, row, index) {
    return '<a href="/admin/news/'+row.news_id+'/edit">Edit</a>&nbsp;|&nbsp;<a href="/admin/news/'+row.news_id+'/delete">Delete</a>';
}

function formatSponsorsDelete(value, row, index) {
    return '<a href="/admin/sponsors/'+row.sponsor_id+'/edit">Edit</a>&nbsp;|&nbsp;<a href="/admin/sponsors/'+row.sponsor_id+'/delete">Delete</a>';
}


