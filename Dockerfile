# Define a imagem base
FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive

# Atualiza o sistema e instala as dependências
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y \
    apache2 \
    php7.4 \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-intl \
    php7.4-mbstring \
    php7.4-xmlrpc \
    php7.4-zip \
    unzip

# Baixa o pacote do Moodle
RUN apt-get install -y wget \
    && wget https://download.moodle.org/download.php/direct/stable311/moodle-latest-311.tgz \
    && tar -xf moodle-latest-311.tgz \
    && mv moodle /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Cria o diretório moodledata e define as permissões
RUN mkdir /var/www/html/moodledata \
    && chown -R www-data:www-data /var/www/html/moodledata \
    && chmod -R 755 /var/www/html/moodledata

# Configuração do Apache
RUN a2enmod rewrite
COPY moodle.conf /etc/apache2/sites-available/moodle.conf
RUN ln -s /etc/apache2/sites-available/moodle.conf /etc/apache2/sites-enabled/moodle.conf
RUN rm /etc/apache2/sites-enabled/000-default.conf

RUN sed -i '/<Directory \/var\/www\/html>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf


# Expor a porta 80 do Apache
EXPOSE 80

# Comando para iniciar o Apache
CMD ["apache2ctl", "-D", "FOREGROUND"]
