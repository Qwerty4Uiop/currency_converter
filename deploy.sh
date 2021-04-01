function start()
{
    docker-compose up web
}

function test()
{
    docker-compose build web
    docker-compose run test
}

while getopts "st" option
do
    case "${option}"
    in
        s) start;;
        t) test;;
    esac
done