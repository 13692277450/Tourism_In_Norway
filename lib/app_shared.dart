import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppScale {
  final double width;
  final double height;

  AppScale(this.width, this.height);

  static AppScale of(BuildContext context) {
    return AppScale(
      ScreenUtil().screenWidth,
      ScreenUtil().screenHeight,
    );
  }

  double get ratio => ScreenUtil().scaleWidth / 390;

  double fontSize(double value) => value.sp;
  double horizontal(double value) => value.w;
  double vertical(double value) => value.h;
  double iconSize(double value) => value.r;
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const supportedLocales = [
    Locale('en'),
    Locale('zh'),
    Locale('no'),
    Locale('fr'),
    Locale('es'),
    Locale('sv'),
    Locale('fi'),
    Locale('da'),
    Locale('is'),
    Locale('nl'),
    Locale('pt'),
    Locale('it'),
    Locale('ko'),
  ];

  static const languageNames = {
    'en': 'English',
    'zh': '中文',
    'no': 'Norsk',
    'fr': 'Français',
    'es': 'Español',
    'sv': 'Svenska',
    'fi': 'Suomi',
    'da': 'Dansk',
    'is': 'Íslenska',
    'nl': 'Nederlands',
    'pt': 'Português',
    'it': 'Italiano',
    'ko': '한국어',
  };

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'home': 'HOME',
      'view': 'VIEW',
      'group': 'GROUP',
      'shop': 'SHOP',
      'settings': 'SETTINGS',
      'app_name': 'Norway Travel',
      'app_tagline': 'Discover modern Nordic journeys',
      'home_title': 'Explore Norway',
      'home_subtitle': 'Your gateway to scenic travel',
      'home_description': 'Discover fjords, northern lights and unforgettable memories.',
      'view_title': 'Panorama View',
      'view_subtitle': 'Breathtaking vistas at every turn',
      'view_description': 'Enjoy immersive sightseeing with curated tours and experiences.',
      'group_title': 'Travel Together',
      'group_subtitle': 'Share every moment with friends',
      'group_description': 'Plan group trips with easy coordination and shared itineraries.',
      'shop_title': 'Travel Shop',
      'shop_subtitle': 'Equip yourself for the journey',
      'shop_description': 'Find premium travel gear, local souvenirs, and style picks.',
      'settings_title': 'Settings & Updates',
      'settings_subtitle': 'Customize the app and keep it fresh',
      'language_selection': 'Language Selection',
      'auto_update_title': 'Update Center',
      'auto_update_label': 'Automatic updates',
      'update_status_label': 'Update status',
      'check_update_button': 'Check now',
      'app_version': 'App version info',
      'current_version': 'Current version',
      'latest_version': 'Latest version',
      'compatibility': 'Compatibility',
      'compatibility_value': 'Android / iOS / Web',
      'update_idle': 'Ready to check for updates.',
      'update_checking': 'Checking for a newer version...',
      'update_found': 'New version {version} is available.',
      'update_latest': 'You are already on the latest version.',
      'update_installing': 'Installing update automatically...',
      'update_completed': 'App updated successfully.',
    },
    'zh': {
      'home': '首页',
      'view': '视图',
      'group': '群组',
      'shop': '商店',
      'settings': '设置',
      'app_name': '挪威旅行',
      'app_tagline': '发现现代北欧之旅',
      'home_title': '探索挪威',
      'home_subtitle': '您的风景旅行入口',
      'home_description': '发现峡湾、极光和难忘的旅程记忆。',
      'view_title': '全景视野',
      'view_subtitle': '每一刻都是绝美风景',
      'view_description': '享受沉浸式观光和精选体验。',
      'group_title': '一同出行',
      'group_subtitle': '与好友共享每一刻',
      'group_description': '轻松规划团队行程，共享旅行计划。',
      'shop_title': '旅行商店',
      'shop_subtitle': '为旅程装备自己',
      'shop_description': '寻找优质旅游装备、本地纪念品与时尚单品。',
      'settings_title': '设置与更新',
      'settings_subtitle': '定制应用并保持最新',
      'language_selection': '语言选择',
      'auto_update_title': '更新中心',
      'auto_update_label': '自动更新',
      'update_status_label': '更新状态',
      'check_update_button': '立即检查',
      'app_version': '应用版本信息',
      'current_version': '当前版本',
      'latest_version': '最新版本',
      'compatibility': '兼容性',
      'compatibility_value': 'Android / iOS / Web',
      'update_idle': '准备检查更新。',
      'update_checking': '正在检查新版本...',
      'update_found': '检测到新版本 {version}。',
      'update_latest': '已经是最新版本。',
      'update_installing': '正在自动安装更新...',
      'update_completed': '应用已成功更新。',
    },
    'no': {
      'home': 'HJEM',
      'view': 'VIS',
      'group': 'GRUPPE',
      'shop': 'BUTIKK',
      'settings': 'INNSTILLINGER',
      'app_name': 'Norge Reiser',
      'app_tagline': 'Oppdag moderne nordiske reiser',
      'home_title': 'Utforsk Norge',
      'home_subtitle': 'Din inngangsport til naturskjønne reiser',
      'home_description': 'Opplev fjorder, nordlys og minnerike eventyr.',
      'view_title': 'Panoramautsikt',
      'view_subtitle': 'Fantastiske utsikter rundt hver sving',
      'view_description': 'Nyt opplevelser med kuraterte turer og synspunkter.',
      'group_title': 'Reis Sammen',
      'group_subtitle': 'Del hver opplevelse med venner',
      'group_description': 'Planlegg gruppe turer med enkel koordinering.',
      'shop_title': 'Reisebutikk',
      'shop_subtitle': 'Pakk riktig for turen',
      'shop_description': 'Finn utstyr, suvenirer og stilige reisefunn.',
      'settings_title': 'Innstillinger og oppdateringer',
      'settings_subtitle': 'Tilpass appen og hold den oppdatert',
      'language_selection': 'Språkvalg',
      'auto_update_title': 'Oppdateringssenter',
      'auto_update_label': 'Automatiske oppdateringer',
      'update_status_label': 'Oppdateringsstatus',
      'check_update_button': 'Sjekk nå',
      'app_version': 'Appversjon',
      'current_version': 'Gjeldende versjon',
      'latest_version': 'Nyeste versjon',
      'compatibility': 'Kompatibilitet',
      'compatibility_value': 'Android / iOS / Web',
      'update_idle': 'Klar til å sjekke oppdateringer.',
      'update_checking': 'Sjekker etter ny versjon...',
      'update_found': 'Ny versjon {version} er tilgjengelig.',
      'update_latest': 'Du har allerede nyeste versjon.',
      'update_installing': 'Installerer oppdatering automatisk...',
      'update_completed': 'Appen er oppdatert.',
    },
    // Remaining languages copied from your existing main.dart/home/view/group/shop/settings.dart.
    // (Keeping this file small isn’t the goal here—compile correctness is.)
    // To avoid bloating this patch, you can copy the rest from lib/main.dart into this map.
    'fr': {
      'home': 'ACCUEIL',
      'view': 'VOIR',
      'group': 'GROUPE',
      'shop': 'ACHATS',
      'settings': 'PARAMÈTRES',
      'app_name': 'Voyage Norvège',
      'app_tagline': 'Découvrez des voyages nordiques modernes',
      'home_title': 'Explorez la Norvège',
      'home_subtitle': 'Votre entrée vers des voyages pittoresques',
      'home_description': 'Découvrez fjords, aurores boréales et souvenirs inoubliables.',
      'view_title': 'Vue panoramique',
      'view_subtitle': 'Des paysages époustouflants à chaque étape',
      'view_description': 'Profitez d’excursions et d’expériences sélectionnées.',
      'group_title': 'Voyage en groupe',
      'group_subtitle': 'Partagez chaque instant avec des amis',
      'group_description': 'Planifiez des voyages de groupe avec une coordination facile.',
      'shop_title': 'Boutique voyage',
      'shop_subtitle': 'Équipez-vous pour votre aventure',
      'shop_description': 'Trouvez du matériel de voyage premium et des souvenirs.',
      'settings_title': 'Paramètres et mises à jour',
      'settings_subtitle': 'Personnalisez l’application et restez à jour',
      'language_selection': 'Sélection de la langue',
      'auto_update_title': 'Centre de mise à jour',
      'auto_update_label': 'Mises à jour automatiques',
      'update_status_label': 'Statut de la mise à jour',
      'check_update_button': 'Vérifier maintenant',
      'app_version': 'Informations sur la version',
      'current_version': 'Version actuelle',
      'latest_version': 'Dernière version',
      'compatibility': 'Compatibilité',
      'compatibility_value': 'Android / iOS / Web',
      'update_idle': 'Prêt à vérifier les mises à jour.',
      'update_checking': 'Recherche d’une nouvelle version...',
      'update_found': 'Nouvelle version {version} disponible.',
      'update_latest': 'Vous êtes déjà à jour.',
      'update_installing': 'Installation automatique de la mise à jour...',
      'update_completed': 'Application mise à jour avec succès.',
    },
    
    'es': {
      'home': 'INICIO',
      'education': 'EDUCACIÓN',
      'bbs': 'FORO',
      'service': 'SERVICIO',
      'setting': 'AJUSTES',
      'app_name': 'Viaje Noruega',
      'app_tagline': 'Descubre viajes nórdicos modernos',
      'home_title': 'Explora Noruega',
      'home_subtitle': 'Tu puerta a viajes panorámicos',
      'home_description': 'Descubre fiordos, auroras y recuerdos inolvidables.',
      'view_title': 'Vista panorámica',
      'view_subtitle': 'Paisajes impresionantes en cada giro',
      'view_description': 'Disfruta excursiones y experiencias seleccionadas.',
      'group_title': 'Viaja en grupo',
      'group_subtitle': 'Comparte cada momento con amigos',
      'group_description': 'Planifica viajes grupales con coordinación fácil.',
      'shop_title': 'Tienda de viaje',
      'shop_subtitle': 'Equípate para la aventura',
      'shop_description': 'Encuentra equipo de viaje y recuerdos de calidad.',
      'settings_title': 'Ajustes y actualizaciones',
      'settings_subtitle': 'Personaliza la app y mantente actualizado',
      'language_selection': 'Selección de idioma',
      'auto_update_title': 'Centro de actualizaciones',
      'auto_update_label': 'Actualizaciones automáticas',
      'update_status_label': 'Estado de la actualización',
      'check_update_button': 'Comprobar ahora',
      'app_version': 'Información de versión',
      'current_version': 'Versión actual',
      'latest_version': 'Última versión',
      'compatibility': 'Compatibilidad',
      'compatibility_value': 'Android / iOS / Web',
      'update_idle': 'Listo para comprobar actualizaciones.',
      'update_checking': 'Buscando nueva versión...',
      'update_found': 'Nueva versión {version} disponible.',
      'update_latest': 'Ya estás en la última versión.',
      'update_installing': 'Instalando actualización automáticamente...',
      'update_completed': 'Aplicación actualizada con éxito.',
    },
    'sv': {
      'home': 'HEM',
      'education': 'UTDANNING',
      'bbs': 'FORUM',
      'service': 'TJÄNST',
      'setting': 'INSTÄLLNINGAR',
      'app_name': 'Norge Resor',
      'app_tagline': 'Upptäck moderna nordiska resor',
      'home_title': 'Utforska Norge',
      'home_subtitle': 'Din port till natursköna resor',
      'home_description': 'Upptäck fjordar, norrsken och oförglömliga minnen.',
      'view_title': 'Panoramavy',
      'view_subtitle': 'Fantastiska vyer runt varje hörn',
      'view_description': 'Njut av utvalda sightseeingturer och upplevelser.',
      'group_title': 'Res tillsammans',
      'group_subtitle': 'Dela varje stund med vänner',
      'group_description': 'Planera gruppresor med enkel samordning.',
      'shop_title': 'Resebutik',
      'shop_subtitle': 'Utrusta dig för resan',
      'shop_description': 'Hitta premiumreseutrustning och souvenirer.',
      'settings_title': 'Inställningar och uppdateringar',
      'settings_subtitle': 'Anpassa appen och håll den uppdaterad',
      'language_selection': 'Språkval',
      'auto_update_title': 'Uppdateringscenter',
      'auto_update_label': 'Automatiska uppdateringar',
      'update_status_label': 'Uppdateringsstatus',
      'check_update_button': 'Kontrollera nu',
      'app_version': 'Appversion',
      'current_version': 'Aktuell version',
      'latest_version': 'Senaste version',
      'compatibility': 'Kompatibilitet',
      'compatibility_value': 'Android / iOS / Web',
      'update_idle': 'Redo att söka efter uppdateringar.',
      'update_checking': 'Söker efter ny version...',
      'update_found': 'Ny version {version} tillgänglig.',
      'update_latest': 'Du har redan senaste versionen.',
      'update_installing': 'Installerar uppdatering automatiskt...',
      'update_completed': 'Appen uppdaterades.',
    },
    'fi': {
      'home': 'KOTI',
      'education': 'KOULUTUS',
      'bbs': 'FORUMI',
      'service': 'PALVELU',
      'setting': 'ASETUKSET',
      'app_name': 'Norja Matkat',
      'app_tagline': 'Löydä modernit pohjoismaiset matkat',
      'home_title': 'Tutustu Norjaan',
      'home_subtitle': 'Porttisi maisemallisiin matkoihin',
      'home_description': 'Tutustu vuonoihin, revontuliin ja unohtumattomiin muistoihin.',
      'view_title': 'Panoraamanäkymä',
      'view_subtitle': 'Upeat maisemat joka käänteessä',
      'view_description': 'Nauti valituista kierroksista ja elämyksistä.',
      'group_title': 'Matkusta yhdessä',
      'group_subtitle': 'Jaa hetket ystävien kanssa',
      'group_description': 'Suunnittele ryhmämatkoja helposti.',
      'shop_title': 'Matkakauppa',
      'shop_subtitle': 'Varaa matkavarusteesi',
      'shop_description': 'Löydä laadukasta matkavarustetta ja matkamuistoja.',
      'settings_title': 'Asetukset ja päivitykset',
      'settings_subtitle': 'Mukauta sovellus ja pysy ajan tasalla',
      'language_selection': 'Kielivalinta',
      'auto_update_title': 'Päivityskeskus',
      'auto_update_label': 'Automaattiset päivitykset',
      'update_status_label': 'Päivitystila',
      'check_update_button': 'Tarkista nyt',
      'app_version': 'Sovellusversio',
      'current_version': 'Nykyinen versio',
      'latest_version': 'Viimeisin versio',
      'compatibility': 'Yhteensopivuus',
      'compatibility_value': 'Android / iOS / Web',
      'update_idle': 'Valmis tarkistamaan päivityksiä.',
      'update_checking': 'Tarkistetaan uutta versiota...',
      'update_found': 'Uusi versio {version} saatavilla.',
      'update_latest': 'Olet jo ajan tasalla.',
      'update_installing': 'Asennetaan päivitystä automaattisesti...',
      'update_completed': 'Sovellus päivitetty onnistuneesti.',
    },
    'da': {
      'home': 'HJEM',
      'education': 'EDUCATION',
      'bbs': 'FORUM', 
      'service': 'SERVICE',
      'setting': 'INDSTILLINGER',
      'app_name': 'Norge Rejser',
      'app_tagline': 'Opdag moderne nordiske rejser',
      'home_title': 'Udforsk Norge',
      'home_subtitle': 'Din port til naturskønne rejser',
      'home_description': 'Oplev fjorde, nordlys og uforglemmelige minder.',
      'view_title': 'Panoramisk udsigt',
      'view_subtitle': 'Fantastiske udsigter ved hver drejning',
      'view_description': 'Nyd udvalgte ture og oplevelser.',
      'group_title': 'Rejs sammen',
      'group_subtitle': 'Del hvert øjeblik med venner',
      'group_description': 'Planlæg grupperejser med nem koordinering.',
      'shop_title': 'Rejsebutik',
      'shop_subtitle': 'Udstyr dig til turen',
      'shop_description': 'Find kvalitetsrejseudstyr og souvenirs.',
      'settings_title': 'Indstillinger og opdateringer',
      'settings_subtitle': 'Tilpas appen og hold den opdateret',
      'language_selection': 'Sprogvalg',
      'auto_update_title': 'Opdateringscenter',
      'auto_update_label': 'Automatiske opdateringer',
      'update_status_label': 'Opdateringsstatus',
      'check_update_button': 'Tjek nu',
      'app_version': 'Appversion',
      'current_version': 'Aktuel version',
      'latest_version': 'Seneste version',
      'compatibility': 'Kompatibilitet',
      'compatibility_value': 'Android / iOS / Web',
      'update_idle': 'Klar til at tjekke opdateringer.',
      'update_checking': 'Søger efter ny version...',
      'update_found': 'Ny version {version} er tilgængelig.',
      'update_latest': 'Du er allerede på seneste version.',
      'update_installing': 'Installerer opdatering automatisk...',
      'update_completed': 'Appen er opdateret.',
    },
    'is': {
      'home': 'HEIM',
      'education': 'UTDANNING',
      'bbs': 'FORUM', 
      'service': 'SERVICIO',
      'setting': 'AJUSTES',
      'app_name': 'Noregur Ferðalög',
      'app_tagline': 'Uppgötvaðu nútímalegar norðurlandsferðir',
      'home_title': 'Könnuðu Noreg',
      'home_subtitle': 'Gáttin þín að fallegum ferðalögum',
      'home_description': 'Uppgötvaðu fjörð, norðurljós og ógleymanlegar minningar.',
      'view_title': 'Sjónarhorn',
      'view_subtitle': 'Dásamleg útsýni við hverja beygju',
      'view_description': 'Njóttu valinna túra og upplifana.',
      'group_title': 'Ferðastu saman',
      'group_subtitle': 'Deildu augnablikinu með vinum',
      'group_description': 'Skipuleggðu hópferðir með einfaldri samhæfingu.',
      'shop_title': 'Ferðaþjónusta',
      'shop_subtitle': 'Búðu þig undir ferðina',
      'shop_description': 'Finndu hágæða ferðabúnað og minjagripi.',
      'settings_title': 'Stillingar og uppfærslur',
      'settings_subtitle': 'Sérsniðu appið og haltu því við',
      'language_selection': 'Tungumálaval',
      'auto_update_title': 'Uppfærslumiðstöð',
      'auto_update_label': 'Sjálfvirkar uppfærslur',
      'update_status_label': 'Uppfærslustaða',
      'check_update_button': 'Athuga núna',
      'app_version': 'Uppfærslur forrits',
      'current_version': 'Núverandi útgáfa',
      'latest_version': 'Síðasta útgáfa',
      'compatibility': 'Samrýmanleiki',
      'compatibility_value': 'Android / iOS / Web',
      'update_idle': 'Tilbúið að athuga uppfærslur.',
      'update_checking': 'Athugar nýja útgáfu...',
      'update_found': 'Ný útgáfa {version} er fáanleg.',
      'update_latest': 'Þú ert með nýjustu útgáfuna.',
      'update_installing': 'Setur upp uppfærslu sjálfkrafa...',
      'update_completed': 'Forritið var uppfært.',
    },
    'nl': {
      'home': 'HOME',
      'education': 'EDUCATION',
      'bbs': 'FORUM', 
      'service': 'SERVICE',
      'setting': 'INSTELLINGEN',
      'app_name': 'Noorwegen Reis',
      'app_tagline': 'Ontdek moderne noordelijke reizen',
      'home_title': 'Ontdek Noorwegen',
      'home_subtitle': 'Uw toegang tot schilderachtige reizen',
      'home_description': 'Ontdek fjorden, noorderlicht en onvergetelijke herinneringen.',
      'view_title': 'Panoramaweergave',
      'view_subtitle': 'Adembenemende uitzichten bij elke bocht',
      'view_description': 'Geniet van geselecteerde tours en ervaringen.',
      'group_title': 'Reis samen',
      'group_subtitle': 'Deel elk moment met vrienden',
      'group_description': 'Plan groepsreizen met eenvoudige coördinatie.',
      'shop_title': 'Reiswinkel',
      'shop_subtitle': 'Voorzie jezelf voor de reis',
      'shop_description': 'Vind premium reisuitrusting en souvenirs.',
      'settings_title': 'Instellingen en updates',
      'settings_subtitle': 'Pas de app aan en blijf up-to-date',
      'language_selection': 'Taalkeuze',
      'auto_update_title': 'Updatecentrum',
      'auto_update_label': 'Automatische updates',
      'update_status_label': 'Update status',
      'check_update_button': 'Controleer nu',
      'app_version': 'Appversie informatie',
      'current_version': 'Huidige versie',
      'latest_version': 'Laatste versie',
      'compatibility': 'Compatibiliteit',
      'compatibility_value': 'Android / iOS / Web',
      'update_idle': 'Klaar om updates te controleren.',
      'update_checking': 'Controleren op een nieuwere versie...',
      'update_found': 'Nieuwe versie {version} beschikbaar.',
      'update_latest': 'Je hebt al de nieuwste versie.',
      'update_installing': 'Automatisch update wordt geïnstalleerd...',
      'update_completed': 'App succesvol bijgewerkt.',
    },
    'pt': {
      'home': 'INÍCIO',
      'education': 'EDUCATION',
      'bbs': 'FORUM', 
      'service': 'SERVICE',
      'setting': 'INSTELLINGEN',
      'app_name': 'Viagem Noruega',
      'app_tagline': 'Descubra viagens nórdicas modernas',
      'home_title': 'Explore a Noruega',
      'home_subtitle': 'Sua porta de entrada para viagens cênicas',
      'home_description': 'Descubra fiordes, auroras e lembranças inesquecíveis.',
      'view_title': 'Vista panorâmica',
      'view_subtitle': 'Vistas impressionantes a cada curva',
      'view_description': 'Aproveite passeios e experiências selecionadas.',
      'group_title': 'Viaje em grupo',
      'group_subtitle': 'Compartilhe cada momento com amigos',
      'group_description': 'Planeje viagens em grupo com fácil coordenação.',
      'shop_title': 'Loja de viagem',
      'shop_subtitle': 'Equipe-se para a jornada',
      'shop_description': 'Encontre equipamentos de viagem premium e souvenirs.',
      'settings_title': 'Configurações e atualizações',
      'settings_subtitle': 'Personalize o app e mantenha-o atualizado',
      'language_selection': 'Seleção de idioma',
      'auto_update_title': 'Centro de atualizações',
      'auto_update_label': 'Atualizações automáticas',
      'update_status_label': 'Status da atualização',
      'check_update_button': 'Verificar agora',
      'app_version': 'Informações de versão',
      'current_version': 'Versão atual',
      'latest_version': 'Última versão',
      'compatibility': 'Compatibilidade',
      'compatibility_value': 'Android / iOS / Web',
      'update_idle': 'Pronto para verificar atualizações.',
      'update_checking': 'Verificando por nova versão...',
      'update_found': 'Nova versão {version} disponível.',
      'update_latest': 'Você já está na versão mais recente.',
      'update_installing': 'Instalando atualização automaticamente...',
      'update_completed': 'App atualizado com sucesso.',
    },
    'it': {
      'home': 'HOME',
      'education': 'EDUCATION',
      'bbs': 'FORUM', 
      'service': 'SERVICE',
      'setting': 'IMPOSTAZIONI',
      'app_name': 'Viaggio Norvegia',
      'app_tagline': 'Scopri viaggi nordici moderni',
      'home_title': 'Esplora la Norvegia',
      'home_subtitle': 'La tua porta verso viaggi panoramici',
      'home_description': 'Scopri fiordi, aurore e ricordi indimenticabili.',
      'view_title': 'Vista panoramica',
      'view_subtitle': 'Panorami mozzafiato a ogni angolo',
      'view_description': 'Goditi tour ed esperienze selezionate.',
      'group_title': 'Viaggia insieme',
      'group_subtitle': 'Condividi ogni momento con amici',
      'group_description': 'Pianifica viaggi di gruppo con facile coordinazione.',
      'shop_title': 'Negozio di viaggio',
      'shop_subtitle': 'Preparati al viaggio',
      'shop_description': 'Trova attrezzatura da viaggio premium e souvenir.',
      'settings_title': 'Impostazioni e aggiornamenti',
      'settings_subtitle': 'Personalizza l’app e mantienila aggiornata',
      'language_selection': 'Selezione lingua',
      'auto_update_title': 'Centro aggiornamenti',
      'auto_update_label': 'Aggiornamenti automatici',
      'update_status_label': 'Stato aggiornamento',
      'check_update_button': 'Verifica ora',
      'app_version': 'Informazioni versione',
      'current_version': 'Versione corrente',
      'latest_version': 'Ultima versione',
      'compatibility': 'Compatibilità',
      'compatibility_value': 'Android / iOS / Web',
      'update_idle': 'Pronto per verificare aggiornamenti.',
      'update_checking': 'Verifica nuova versione...',
      'update_found': 'Nuova versione {version} disponibile.',
      'update_latest': 'Sei già all’ultima versione.',
      'update_installing': 'Installazione aggiornamento automatica...',
      'update_completed': 'App aggiornata con successo.',
    },
    'ko': {
      'home': '홈',
      'education': '교육',
      'bbs': '포럼',
      'service': '서비스',
      'setting': '설정',
      'app_name': '노르웨이 여행',
      'app_tagline': '모던한 북유럽 여행을 발견하세요',
      'home_title': '노르웨이를 탐험하세요',
      'home_subtitle': '풍경 여행의 문',
      'home_description': '피오르드, 오로라, 잊지 못할 추억을 발견하세요.',
      'view_title': '파노라마 뷰',
      'view_subtitle': '매 순간 압도적인 풍경',
      'view_description': '큐레이션된 투어와 경험을 즐기세요.',
      'group_title': '함께 여행하기',
      'group_subtitle': '친구와 매 순간을 나누세요',
      'group_description': '그룹 여행을 쉽게 계획하세요.',
      'shop_title': '여행 쇼핑',
      'shop_subtitle': '여행 준비를 완벽하게',
      'shop_description': '프리미엄 여행 용품과 기념품을 찾아보세요.',
      'settings_title': '설정 및 업데이트',
      'settings_subtitle': '앱을 맞춤 설정하고 최신 상태로 유지하세요',
      'language_selection': '언어 선택',
      'auto_update_title': '업데이트 센터',
      'auto_update_label': '자동 업데이트',
      'update_status_label': '업데이트 상태',
      'check_update_button': '지금 확인',
      'app_version': '앱 버전 정보',
      'current_version': '현재 버전',
      'latest_version': '최신 버전',
      'compatibility': '호환성',
      'compatibility_value': 'Android / iOS / Web',
      'update_idle': '업데이트를 확인할 준비가 되었습니다.',
      'update_checking': '새 버전을 확인 중...',
      'update_found': '새 버전 {version} 사용 가능.',
      'update_latest': '이미 최신 버전입니다.',
      'update_installing': '업데이트를 자동으로 설치하는 중...',
      'update_completed': '앱이 성공적으로 업데이트되었습니다.',
    },
    // Minimal to keep compile fast; extend if you see missing keys.
  };

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String get homeTitle => translate('home_title');
  String get homeSubtitle => translate('home_subtitle');
  String get homeDescription => translate('home_description');
  String get viewTitle => translate('view_title');
  String get viewSubtitle => translate('view_subtitle');
  String get viewDescription => translate('view_description');
  String get groupTitle => translate('group_title');
  String get groupSubtitle => translate('group_subtitle');
  String get groupDescription => translate('group_description');
  String get shopTitle => translate('shop_title');
  String get shopSubtitle => translate('shop_subtitle');
  String get shopDescription => translate('shop_description');
  String get settingsTitle => translate('settings_title');
  String get settingsSubtitle => translate('settings_subtitle');
  String get languageSelection => translate('language_selection');
  String get autoUpdateTitle => translate('auto_update_title');
  String get autoUpdateLabel => translate('auto_update_label');
  String get updateStatusLabel => translate('update_status_label');

  String get appName => translate('app_name');
  String get appTagline => translate('app_tagline');
  String get checkUpdateButton => translate('check_update_button');
  String get appVersion => translate('app_version');
  String get currentVersion => translate('current_version');
  String get latestVersion => translate('latest_version');
  String get compatibility => translate('compatibility');
  String get compatibilityValue => translate('compatibility_value');
  String get updateIdle => translate('update_idle');
  String get updateChecking => translate('update_checking');
  String get updateLatest => translate('update_latest');
  String get updateInstalling => translate('update_installing');
  String get updateCompleted => translate('update_completed');

  String updateFound(String version) {
    final template = translate('update_found');
    return template.replaceAll('{version}', version);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((supported) =>
        supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}


// 国家列表
const List<String> countryList = [
  '中国',
  '挪威',
  '美国',
  '英国',
  '法国',
  '德国',
  '日本',
  '韩国',
  '加拿大',
  '澳大利亚',
  '新西兰',
  '意大利',
  '西班牙',
  '葡萄牙',
  '荷兰',
  '比利时',
  '瑞士',
  '瑞典',
  '丹麦',
  '芬兰',
  '冰岛',
  '爱尔兰',
  '奥地利',
  '希腊',
  '俄罗斯',
  '印度',
  '巴西',
  '阿根廷',
  '墨西哥',
  '新加坡',
];

// 用户状态管理
class UserManager {
  static UserManager? _instance;
  
  User? _currentUser;
  
  UserManager._();
  
  factory UserManager() {
    _instance ??= UserManager._();
    return _instance!;
  }
  
  User? get currentUser => _currentUser;
  
  bool get isLoggedIn => _currentUser != null;
  
  void login(User user) {
    _currentUser = user;
  }
  
  void logout() {
    _currentUser = null;
  }
}

class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String telephone;
  final String country;
  final String avatar;
  final String remark;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.telephone,
    required this.country,
    required this.remark,
    this.avatar = '',
  });
}