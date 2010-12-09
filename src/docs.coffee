# Quick and dirty implementation of
# [code-illuminated](http://code.google.com/p/code-illuminated/)-esque
# documentation system. Imported from [src/index.html](#).

navi = document.getElementById 'navi'
docs = document.getElementById 'docs'
sdcv = new Showdown.converter
htms = __proto__: null

do @onhashchange = ->
  unless page = /^\D+(?=(\d*)$)/.exec location.hash.slice 1
    navi.className = docs.innerHTML = ''
    return
  navi.className = 'menu'
  docs.innerHTML = '...'
  [name] = page
  return load page, htms[name] if name in htms
  xhr = new XMLHttpRequest
  xhr.open 'GET', name + '.coffee', true
  xhr.overrideMimeType? 'text/plain'
  xhr.onreadystatechange = ->
    if xhr.readyState is 4
      load page, htms[name] = "<h1>#{name}</h1>" + build xhr.responseText
  xhr.send null

load = ([name, sect], html) ->
  document.title = name + ' - Coco Docs'
  docs.innerHTML = html
  document.getElementById(sect).scrollIntoView() if sect
  prettyPrint()

build = (source) ->
  htm = comment = code = i = ''
  re  = /^[^\n\S]*#(?!##[^#]|{) ?(.*)/
  for line of source.split '\n'
    unless line
      br = true
      code &&+= '\n'
      continue
    if m = re.exec line
      if code or comment and br
        htm += block comment, code, i++
        comment = code = ''
      comment += m.1 + '\n'
    else
      code += line + '\n'
    br = false
  htm += block comment, code, i if comment
  htm

block = (comment, code, i) ->
  code &&= """
   <pre class="code prettyprint lang-coffee"
    >#{ code.replace(/&/g, '&amp;').replace(/</g, '&lt;') }</pre>
  """
  """
   <div id=#{i} class=block><div class=comment
    ><a class=anchor href=##{name}#{i}>##{i}</a
    >#{ sdcv.makeHtml comment }</div
    >#{code}</div>
  """
