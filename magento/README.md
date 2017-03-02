[![Magento](../../raw/master/magento/images/magento.png)](../../../magento)
## Magento

The JPS package deploys Magento that initially contains 1 application server and 1 database container.

### Highlights
This package is designed to deploy Magento environment which represents an open-source e-commerce platform written in PHP.<br />Magento employs the MySQL relational database management system, the PHP programming language, and elements of the Zend Framework. It applies the conventions of object-oriented programming and model–view–controller architecture. Magento also uses the entity–attribute–value model to store data.

### Environment Topology

![Magento Topology](https://docs.google.com/drawings/d/17QKNZokR_XOgG-gzTe2dyd3RaneuHM3mugbjAA8HPoQ/pub?w=505&h=216)

### Specifics

Layer                |     Server    | Number of CTs <br/> by default | Cloudlets per CT <br/> (reserved/dynamic) | Options
-------------------- | --------------| :----------------------------: | :---------------------------------------: | :-----:
AS                   | Apache 2 (MOD_PHP) |       1                        |           1 / 16                          | -
DB                   |    MySQL      |       1                        |           1 / 16                           | -

* AS - Application server 
* DB - Database 
* CT - Container

**Magento Version**: 2.0.4<br/>
**PHP Engine**: PHP 5.5.36<br/>
**MySQL Database**: 5.7.12

### Deployment

In order to get this solution instantly deployed, click the "Get It Hosted Now" button, specify your email address within the widget, choose one of the [Jelastic Public Cloud providers](https://jelastic.cloud) and press Install.

[![GET IT HOSTED](https://raw.githubusercontent.com/jelastic-jps/jpswiki/master/images/getithosted.png)](https://jelastic.com/install-application/?manifest=https%3A%2F%2Fgithub.com%2Fjelastic-jps%2Fmagento%2Fraw%2Fmaster%2Fmanifest.jps)

To deploy this package to Jelastic Private Cloud, import [this JPS manifest](../../raw/master/manifest.jps) within your dashboard ([detailed instruction](https://docs.jelastic.com/environment-export-import#import)).

More information about Jelastic JPS package and about installation widget for your website can be found in the [Jelastic JPS Application Package](https://github.com/jelastic-jps/jpswiki/wiki/Jelastic-JPS-Application-Package) reference.
