FROM basmalltalk/pharo:9.0-image

RUN ./pharo Pharo.image eval --save "Metacello new \
baseline:'TinyBlog'; \
repository: 'github://LucFabresse/TinyBlog/src'; \
onConflict: [ :ex | ex useLoaded ]; \
load"

RUN ./pharo Pharo.image eval --save "TBBlog reset ; createDemoPosts"

EXPOSE 8080/tcp

CMD ./pharo Pharo.image eval --no-quit "ZnZincServerAdaptor startOn: 8080"


