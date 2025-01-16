use Symfony\Component\Dotenv\Dotenv;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;
use Symfony\Component\Routing\RouteCollectionBuilder;
use Symfony\Component\HttpKernel\Kernel;
use Symfony\Component\Config\Loader\LoaderInterface;
use Doctrine\ORM\Tools\Setup;
use Doctrine\ORM\EntityManager;


<?php

    require dirname(__DIR__).'/vendor/autoload.php';

    class AppKernel extends Kernel
    {
        public function registerBundles()
        {
            $bundles = [
                // Register your bundles here
                new Symfony\Bundle\FrameworkBundle\FrameworkBundle(),
                new Doctrine\Bundle\DoctrineBundle\DoctrineBundle(),
            ];

            return $bundles;
        }

        public function registerContainerConfiguration(LoaderInterface $loader)
        {
            $loader->load(__DIR__.'/../config/config.yml');
        }
    }

    class Book
    {
        private $id;
        private $title;
        private $author;
        private $price;

        public function getId()
        {
            return $this->id;
        }

        public function getTitle()
        {
            return $this->title;
        }

        public function setTitle($title)
        {
            $this->title = $title;
        }

        public function getAuthor()
        {
            return $this->author;
        }

        public function setAuthor($author)
        {
            $this->author = $author;
        }

        public function getPrice()
        {
            return $this->price;
        }

        public function setPrice($price)
        {
            $this->price = $price;
        }
    }

    $dotenv = new Dotenv();
    $dotenv->load(__DIR__.'/../.env');

    $isDevMode = true;
    $config = Setup::createAnnotationMetadataConfiguration(array(__DIR__."/src"), $isDevMode);
    $conn = array(
        'dbname' => $_ENV['DB_NAME'],
        'user' => $_ENV['DB_USER'],
        'password' => $_ENV['DB_PASSWORD'],
        'host' => $_ENV['DB_HOST'],
        'driver' => 'pdo_mysql',
    );

    $entityManager = EntityManager::create($conn, $config);

    $request = Request::createFromGlobals();
    $response = new Response();

    $response->setContent('Book catalogue initialized');
    $response->send();

?>