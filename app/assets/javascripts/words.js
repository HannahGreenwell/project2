$(document).ready(() => {

  // const URL = 'https://whichdoodle.herokuapp.com/words';
  const URL = '/words';

  const updateWordGallery = games => {
    $('div.gallery-container').empty();

    games.forEach(drawing => {
      const $imgTag = $('<img>').attr({
        src: 'http://res.cloudinary.com/bored01/image/upload/' + drawing.image,
        class: 'drawing-icon',
        id: drawing.id
      });

      $('<div>')
      .attr('class', 'gallery-drawing')
      .append($imgTag)
      .appendTo($('div.gallery-container'));
    });
  };

  /////  WORD LIST ITEM CLICK HANDLER
  $('li.word').on('click', function() {
    const word_id = $(this).val();
    const word_url = `${URL}/${word_id}`;
    $.getJSON(word_url)
    .done(response => updateWordGallery(response))
    .fail(console.warn);
  });

  /////  GALLERY IMAGE CLICK HANDLER
  ////   To implement if we want a show page (or lightbox) for each drawing
  // $(document).on('click', 'img.drawing-icon', function() {
  //   console.log($(this)[0].id);
  // });

}); // $(document).ready
