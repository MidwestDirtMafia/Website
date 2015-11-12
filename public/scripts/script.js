$(document).ready(function() {
    $("#uploadImageForm").submit(function() {
        $.ajax(
                {
                    type: 'POST',
                    url: '/image',
                    data: $("#uploadImageForm").serialize(),
                    success: function(response)
                    {
                        alert(response);
                        $("#uploadImage").modal('hide');

                    },
                    error: function()
                    {
                        alert("Failure");
                    }
                });

    });
    $("#uploadImageBtn").click(function() {
        $("#uploadImageForm").submit();
    });
    $('#summernote').summernote({
        height: 300,
        onBlur: function() {
            $("#eventDescription").val($("#summernote").code());
        },
        onImageUpload: function(files, editor, welEditable) {
            sendFile(files[0],editor,welEditable);
        }
    });
    $("#eventDescription").val($("#summernote").code());

});


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
            $("#summernote").summernote("insertImage", url, hash);
        }
    });
}
