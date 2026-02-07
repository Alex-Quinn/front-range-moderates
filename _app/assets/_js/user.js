// Custom user scripts

(function () {
  var headers = document.querySelectorAll('th[data-sort]');
  if (!headers.length) return;

  var currentHeader = null;
  var ascending = true;

  headers.forEach(function (th) {
    th.addEventListener('click', function () {
      var table = th.closest('table');
      var tbody = table.querySelector('tbody');
      var rows = Array.prototype.slice.call(tbody.querySelectorAll('tr'));
      var colIndex = Array.prototype.indexOf.call(th.parentNode.children, th);
      var sortType = th.getAttribute('data-sort');

      if (currentHeader === th) {
        ascending = !ascending;
      } else {
        ascending = true;
        currentHeader = th;
      }

      rows.sort(function (a, b) {
        var aText = a.children[colIndex].textContent.trim();
        var bText = b.children[colIndex].textContent.trim();

        if (sortType === 'grade') {
          var aNum = parseInt(aText.replace(/^V/i, ''), 10) || 0;
          var bNum = parseInt(bText.replace(/^V/i, ''), 10) || 0;
          return ascending ? aNum - bNum : bNum - aNum;
        }

        var cmp = aText.toLowerCase().localeCompare(bText.toLowerCase());
        return ascending ? cmp : -cmp;
      });

      rows.forEach(function (row) {
        tbody.appendChild(row);
      });

      // Update arrow indicators
      var neutral = '<span class="arrow-up"></span><span class="arrow-down"></span>';
      headers.forEach(function (h) {
        h.classList.remove('active');
        h.querySelector('.sort-arrow').innerHTML = neutral;
      });
      th.classList.add('active');
      var up = '<span class="arrow-up"></span>';
      var down = '<span class="arrow-down"></span>';
      th.querySelector('.sort-arrow').innerHTML = ascending ? down : up;
    });
  });
})();
