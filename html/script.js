let cwPrintBook = {}
let cwPrintCard = {}
let pages = {}
let currentPage = 0
let totalPages = 0

$(document).ready(function(){
    $('.book-container').hide();
    $('.card-container').hide();

    window.addEventListener('message', function(event){
        var eventData = event.data;

        if (eventData.action == "cwPrintBook") {
            if (eventData.toggle) {
                cwPrintBook.Open(eventData)
            }
        }
        else if (eventData.action == "cwPrintCard") {
            if (eventData.toggle) {
                cwPrintCard.Open(eventData)
            }
        }
    });
});

function setPages() {
    var pages = document.getElementsByClassName('page');
    for(var i = 0; i < pages.length; i++)
      {
        var page = pages[i];
        if (i % 2 === 0)
          {
            page.style.zIndex = (pages.length - i);
          }
      }
  
      for(var i = 0; i < pages.length; i++)
        {
          pages[i].pageNum = i + 1;
          pages[i].onclick=function()
            {
              if (this.pageNum % 2 === 0)
                {
                  this.classList.remove('flipped');
                  this.previousElementSibling.classList.remove('flipped');
                }
              else
                {
                  this.classList.add('flipped');
                  this.nextElementSibling.classList.add('flipped');
                }
             }
          }
}

function handleConfirm() {
}

function handleClose() {
    cwPrintBook.Close()
}

function handlePrevious() {
    if (currentPage > 0) {
        currentPage--
        setPages()
    }
}

function handleNext() {
    if (currentPage < totalPages) {
        currentPage++
        setPages()
    }
}

function createPages(itemPages) {
    $("#pages").html('')
    itemPages.forEach(element => {
        $("#pages").append(`<div class="page"><img src="${element}" class="image" /></div>`)
    });
}

cwPrintBook.Open = function(data) {
    $('.book-container').fadeIn(1000);
    currentPage = 0
    let pagesToCreate = undefined
    if(data.item.metadata) {
        pagesToCreate = data.item.metadata.pages
    } else {
        pagesToCreate = data.item.info.pages
    }
    createPages(pagesToCreate)
    setPages()
}

function createCard(url) {
    $(".card-holder").html('')
    $(".card-holder").append(`<img src="${url}" class="card-image" />`)
}

cwPrintCard.Open = function(data) {
    $('.card-container').fadeIn(1000);
    createCard(data.url)
}

cwPrintBook.Close = function() {
    $('.book-container').fadeOut(250);
    $('.card-container').fadeOut(250);
    $.post('https://cw-prints/closebook-callback');
}

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27:
            cwPrintBook.Close();
            break;
    }
});