let cwPrintBook = {}
let pages = {}
let currentPage = 0
let totalPages = 0

$(document).ready(function(){
    $('.book-container').hide();

    window.addEventListener('message', function(event){
        var eventData = event.data;
        console.log(eventData.action)

        if (eventData.action == "cwPrintBook") {
            if (eventData.toggle) {
                cwPrintBook.Open(eventData)
            }
        }
    });
});

function setPages() {
    console.log('displaying', pages[currentPage])
    if (pages[currentPage][0])
        $('.left-image').attr("src", pages[currentPage][0])
    else
        $('.left-image').attr("src", '')

    if (pages[currentPage][1])
        $('.right-image').attr("src", pages[currentPage][1])
    else        
        $('.right-image').attr("src", '')

}

function handleConfirm() {
    console.log('confirmed', currentAd.title)
}

function handlePrevious() {
    console.log('turning to previous page', currentPage)
    if (currentPage > 0) {
        currentPage--
        setPages()
    }
}

function handleNext() {
    console.log('turning page to next', `${currentPage}/${totalPages}`)
    if (currentPage < totalPages) {
        currentPage++
        setPages()
    }
}

function createPages(itemPages) {
    let tempPages = itemPages
    console.log(tempPages)
    console.log('total pages:',totalPages)
    console.log('tempPages:',tempPages)
    tempPages = tempPages.reduce(function(result, value, index, array) {
        if (index === 0)
            result.push(['',array[0]])
        else if (index % 2 === 0)
          result.push(array.slice(index, index + 2));
        return result;
      }, []);
    pages = tempPages
    totalPages = tempPages.length
    console.log('res', totalPages, tempPages)
}

cwPrintBook.Open = function(data) {
    $('.book-container').fadeIn(1000);
    currentPage = 0
    createPages(data.item.info.pages)
    setPages()
}

cwPrintBook.Close = function() {
    $('.book-container').fadeOut(250);
    $.post('https://cw-prints/closebook-callback');
}

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27:
            cwPrintBook.Close();
            break;
    }
});