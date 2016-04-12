<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:dccd="dccd.lookup" 
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:acdm="http://registry.ariadne-infrastructure.eu/"
	exclude-result-prefixes="xsl xs dccd">
	<!-- ==================================================== -->
	<!-- metadata for ARIADNE Catalogue Data Model (ACDM) -->
	<!-- converting from internal dccd xml (from RESTfull API) -->
	<!-- ==================================================== -->

	<xsl:output indent="yes" encoding="UTF-8"
		omit-xml-declaration="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template match="text()">
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>

	<xsl:template match="/">
		<xsl:call-template name="dccd-root" />
	</xsl:template>

	<xsl:template name="dccd-root">
		<xsl:apply-templates select="project" />
	</xsl:template>

	<xsl:template match="project">
		<acdm:ariadne xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xmlns:acdm="http://registry.ariadne-infrastructure.eu/"
			xmlns:dcat="http://www.w3.org/ns/dcat#" xmlns:dcterms="http://purl.org/dc/terms/"
			xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:foaf="http://xmlns.com/foaf/0.1/"
			xsi:schemaLocation="http://registry.ariadne-infrastructure.eu/ http://registry.ariadne-infrastructure.eu/schema_definition/6.8/acdm.xsd">
			<acdm:ariadneArchaeologicalResource>
			<acdm:collection>
				<xsl:element name="dcterms:isPartOf">
					<xsl:text>dccd</xsl:text>
				</xsl:element>

				<!-- PUBLISHER -->
				<!-- We don't have the publisher of the original data available, 
					 but ARIADNE want to have the publisher of the digital online archive and that is DANS -->
				<xsl:element name="acdm:publisher">
					<foaf:name>Data Archiving and Networked Services (DANS)</foaf:name>
					<acdm:typeOfAnAgent>Organization</acdm:typeOfAnAgent>
					<foaf:mbox>info@dans.knaw.nl</foaf:mbox>
				</xsl:element>

				<!-- CONTRIBUTER -->
				<!-- in acdm contributers are mandatory, it makes no sense, but here it is -->
				<!-- 
				<xsl:element name="acdm:contributor">
					<xsl:call-template name="person-agent">
						<xsl:with-param name="name" select="'Not available'" />
					</xsl:call-template>
				</xsl:element>
				 -->
				<!-- same as owner -->
				<xsl:for-each select="ownerOrganizationId">
					<xsl:element name="acdm:contributor">
						<xsl:element name="foaf:name">
							<xsl:value-of select="text()" />
						</xsl:element>
						<xsl:element name="acdm:typeOfAnAgent">
							<xsl:text>Organization</xsl:text>
						</xsl:element>
						<xsl:element name="foaf:mbox">
							<xsl:text>Not available</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>
				<!-- add investigator (person) if there is one -->
				<xsl:if test="investigator">
					<xsl:element name="acdm:contributor">
						<xsl:call-template name="person-agent">
							<xsl:with-param name="name" select="investigator" />
						</xsl:call-template>
					</xsl:element>
				</xsl:if>

				<!-- CREATOR -->
				<!-- we don't have it -->
				<!--
				<xsl:element name="acdm:creator">
					<xsl:call-template name="person-agent">
						<xsl:with-param name="name" select="'Not available'" />
					</xsl:call-template>
				</xsl:element>
				-->
				<!-- same as owner -->
				<xsl:for-each select="ownerOrganizationId">
					<xsl:element name="acdm:creator">
						<xsl:element name="foaf:name">
							<xsl:value-of select="text()" />
						</xsl:element>
						<xsl:element name="acdm:typeOfAnAgent">
							<xsl:text>Organization</xsl:text>
						</xsl:element>
						<xsl:element name="foaf:mbox">
							<xsl:text>Not available</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>

				<!-- OWNER -->
				<!-- This should indicate an Agent, but we can't guarantee uniquenes -->
				<xsl:for-each select="ownerOrganizationId">
					<xsl:element name="acdm:owner">
						<xsl:element name="foaf:name">
							<xsl:value-of select="text()" />
						</xsl:element>
						<xsl:element name="acdm:typeOfAnAgent">
							<xsl:text>Organization</xsl:text>
						</xsl:element>
						<xsl:element name="foaf:mbox">
							<xsl:text>Not available</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>

				<!--  TECHNICAL RESPONSIBLE, we don't have it! -->
				<!-- acdm:technicalResponsible, could be analyst -->
				<xsl:element name="acdm:technicalResponsible">
					<xsl:call-template name="person-agent">
						<xsl:with-param name="name" select="'Not available'" />
					</xsl:call-template>
				</xsl:element>

				<!-- SUBJECT -->
				<!-- make validation work and specify dendrochronology as subject -->
				<xsl:element name="acdm:ariadneSubject">
					<xsl:comment>Should be replaced by a mapping from the nativeSubject</xsl:comment>
					<xsl:element name="acdm:provided_Subject">
						<xsl:element name="skos:prefLabel">dendrochronology</xsl:element>
						<xsl:element name="dc:source"></xsl:element>
						<xsl:element name="acdm:published"></xsl:element>
						<xsl:element name="dc:language">en</xsl:element>
						<xsl:element name="acdm:provided">True</xsl:element><!-- Yes, I kid you not -->
					</xsl:element>
				</xsl:element>
				<!-- nativeSubject will be mapped to a skos concept (AAT) by the consumer of this -->
				<xsl:for-each select="category">
					<!-- use uri, reference to vocabulary in SKOS -->
					<xsl:element name="acdm:nativeSubject">
						<xsl:element name="skos:Concept">
							<xsl:attribute name="rdf:about">
								<xsl:call-template
									name="dccd_categoryUri">
									<xsl:with-param name="label"
										select="lower-case(text())" />
								</xsl:call-template>
							</xsl:attribute>
							<!-- Also use human readable text -->
							<xsl:element name="skos:prefLabel">
								<xsl:value-of select="text()" />
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>
				<xsl:for-each select="types/type">
					<!-- use uri, reference to vocabulary in SKOS -->
					<xsl:element name="acdm:nativeSubject">
						<xsl:element name="skos:Concept">
							<xsl:attribute name="rdf:about">
								<xsl:call-template
									name="dccd_typeUri">
									<xsl:with-param name="label"
										select="lower-case(text())" />
								</xsl:call-template>
							</xsl:attribute>
							<!-- Also use human readable text -->
							<xsl:element name="skos:prefLabel">
								<xsl:value-of select="text()" />
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>

				<!-- TITLE -->
				<xsl:element name="dcterms:title">
					<xsl:value-of select="title" />
				</xsl:element>

				<!-- DESCRIPTION -->
				<!-- NO dcterms:description; The TRiDaS description is not Open Access information in DCCD -->

				<!-- DATE ISSUED -->
				<xsl:for-each select="stateChanged">
					<xsl:element name="dcterms:issued">
						<xsl:value-of select="text()" />
					</xsl:element>
				</xsl:for-each>

				<!-- DATE MODIFIED -->
				<!-- same as date issued, we only have the (last) archived date we could 
				try to get it from deeper in the TRiDaS -->
				<xsl:for-each select="stateChanged">
					<xsl:element name="dcterms:modified">
						<xsl:value-of select="text()" />
					</xsl:element>
				</xsl:for-each>

				<!-- ORIGINAL IDENTIFIER -->
				<!-- repository id -->
				<xsl:for-each select="sid">
					<xsl:element name="acdm:originalId">
						<!--  Not valid to the schema
						<xsl:attribute name="preferred">true</xsl:attribute>
						 -->
						<xsl:value-of select="text()" />
					</xsl:element>
				</xsl:for-each>
				<!-- TRiDaS project identifier -->
				<!--  Not valid to the schema
				<xsl:element name="acdm:originalId">
					<xsl:attribute name="preferred">false</xsl:attribute>
					<xsl:value-of select="identifier" />
				</xsl:element>
 				-->

				<!-- Note: If we can only have one subject we take the most important 
				and add the others as keywords! But they should be uri's from SKOS vocabularies. -->
				<!-- KEYWORD dcat:keyword -->
				<!-- No URI's yet for the following terms, use keywords instead! -->
				<xsl:for-each select="objectTypes/objectType">
					<xsl:element name="dcat:keyword">
						<xsl:value-of select="text()" />
					</xsl:element>
				</xsl:for-each>
				<xsl:for-each select="elementTypes/elementType">
					<xsl:element name="dcat:keyword">
						<xsl:value-of select="text()" />
					</xsl:element>
				</xsl:for-each>
				<xsl:for-each select="taxons/taxon">
					<xsl:element name="dcat:keyword">
						<xsl:value-of select="text()" />
					</xsl:element>
				</xsl:for-each>
				<!-- TRiDaS project identifier, could not be an originalId -->
				<xsl:element name="dcat:keyword">
					<xsl:value-of select="identifier" />
				</xsl:element>

				<!-- LANGUAGE -->
				<xsl:for-each select="language">
					<xsl:element name="dc:language">
						<xsl:value-of select="text()" />
					</xsl:element>
				</xsl:for-each>

				<!-- LANDING PAGE -->
				<!-- use DCCD identifier -->
				<xsl:for-each select="sid">
					<xsl:element name="dcat:landingPage">
						<xsl:text>http://dendro.dans.knaw.nl/project/</xsl:text>
						<xsl:value-of select="text()" />
					</xsl:element>
				</xsl:for-each>

				<!-- ACCESSPOLICY -->
				<!-- Same for whole collection, but we want to specify 
                this here -->
				<acdm:accessPolicy>
					<xsl:text>http://dendro.dans.knaw.nl/termsofuse</xsl:text>
				</acdm:accessPolicy>

				<!-- accessRights -->
				<xsl:for-each select="permission">
					<xsl:element name="dcterms:accessRights">
						<xsl:choose>
							<xsl:when test="defaultLevel/text()='minimal'">
								<xsl:text>Restricted access for all levels of detail</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>Restricted access for levels more detailed than: </xsl:text>
								<xsl:value-of select="defaultLevel" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:for-each>

				<!-- RIGHTS -->
				<!-- same as policy -->
				<dc:rights>
					<xsl:text>http://dendro.dans.knaw.nl/termsofuse</xsl:text>
				</dc:rights>

				<!-- AUDIENCE -->
				<!-- Same as for whole collection, but we want to specify 
                this here explicitly -->
				<dcterms:audience><xsl:text>Dendrochronologists, Archaeologists, Historians</xsl:text></dcterms:audience>

				<!-- archaeologicalResourceType previously ARIADNESUBJECT -->
				<xsl:element name="acdm:archaeologicalResourceType">
					<xsl:text>Scientific datasets</xsl:text>
				</xsl:element>
				<!-- <dc:type><xsl:text>name=TRiDaS; URI=http://www.tridas.org</xsl:text></dc:type> 
				<dc:format>application/xml</dc:format> -->

				<!-- TEMPORAL -->
				<xsl:for-each select="timeRange">
					<xsl:element name="acdm:temporal">
						<xsl:element name="acdm:periodName">
							<!-- Not available -->
							<!-- could try to get ABR concept from the year-range, 
								but not the wood is from all over europe, so ABR makes no sense! -->
							<!-- Holocene probably covers all our wood samples ;-) -->
							<!-- 
							<xsl:comment>Not available, but this is the most likely range that covers it</xsl:comment>
							<xsl:element name="skos:Concept">
								<xsl:attribute name="rdf:about">
									<xsl:text>http://vocab.getty.edu/aat/300391280</xsl:text>
								</xsl:attribute>
								<xsl:element name="skos:prefLabel">
									<xsl:text>Holocene</xsl:text>
								</xsl:element>
							</xsl:element>
								 -->
							<!-- We would like place the textual representation of the period (range) here, but we need a concept so we can not -->
							<!-- We have a date and a location, so it would be nice if there was a webservice that produced a name -->
							<xsl:comment>Not available</xsl:comment>
							<xsl:element name="skos:Concept">
								<xsl:attribute name="rdf:about">
									<xsl:text>https://en.wikipedia.org/wiki/I_know_that_I_know_nothing</xsl:text>
								</xsl:attribute>
							</xsl:element>
						</xsl:element>
						<xsl:element name="acdm:from">
							<xsl:call-template name="year_to_date">
								<xsl:with-param name="year" select="firstYear" />
							</xsl:call-template>
							<xsl:text>-01-01</xsl:text><!-- suggesting more accuracy, but without is its not valid -->
						</xsl:element>
						<xsl:element name="acdm:until">
							<xsl:call-template name="year_to_date">
								<xsl:with-param name="year" select="lastYear" />
							</xsl:call-template>
							<xsl:text>-12-31</xsl:text><!-- suggesting more accuracy, but without is its not valid -->
						</xsl:element>
					</xsl:element>
				</xsl:for-each>

				<!-- SPATIAL -->
				<xsl:for-each select="location">
					<!-- point -->
					<xsl:element name="acdm:spatial">
						<xsl:element name="acdm:placeName">
							<!-- We don't have the placename (could do search via geonames)
							The title mostly contains the placename but better use the coordinates (lat,lng) here so the UI will show something reasonable -->
							<xsl:value-of select="lat" /><xsl:text>, </xsl:text><xsl:value-of select="lng" />
						</xsl:element>
						<xsl:element name="acdm:coordinateSystem">
							<xsl:text>http://www.opengis.net/def/crs/EPSG/0/4326</xsl:text>
						</xsl:element>
						<xsl:element name="acdm:lat">
							<xsl:value-of select="lat" />
						</xsl:element>
						<xsl:element name="acdm:lon">
							<xsl:value-of select="lng" />
						</xsl:element>
						<xsl:element name="acdm:country">
							<xsl:text>Not available</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>
				<!-- spatial is mandetory, so we add one even if we have none! -->
				<xsl:if test="not(location)">
					<xsl:element name="acdm:spatial">
						<xsl:comment>Not available</xsl:comment>
						<xsl:element name="acdm:placeName">
							<xsl:text>Not available</xsl:text>
						</xsl:element>
						<!-- box approximate for The European continent ;-) -->
						<!-- 
						<xsl:element name="acdm:coordinateSystem">
							<xsl:text>http://www.opengis.net/def/crs/EPSG/0/4326</xsl:text>
						</xsl:element>
						<xsl:element name="acdm:boundingBoxMinLat">
							<xsl:text>34</xsl:text>
						</xsl:element>
						<xsl:element name="acdm:boundingBoxMinLon">
							<xsl:text>-24</xsl:text>
						</xsl:element>
						<xsl:element name="acdm:boundingBoxMaxLat">
							<xsl:text>72</xsl:text>
						</xsl:element>
						<xsl:element name="acdm:boundingBoxMaxLon">
							<xsl:text>35</xsl:text>
						</xsl:element>
						 -->
						<xsl:element name="acdm:country">
							<xsl:text>Not available</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:if>

				<!-- DISTRIBUTION -->
				<xsl:element name="acdm:distribution">
					<xsl:element name="dcterms:title">
						<xsl:text>DCCD Archive</xsl:text>
					</xsl:element>
					<xsl:element name="dcterms:issued">
						<xsl:value-of select="stateChanged" />
					</xsl:element>
					<xsl:element name="dcterms:modified">
						<xsl:value-of select="stateChanged" />
					</xsl:element>
					<xsl:element name="dcat:accessURL">
						<!-- same as landingpage -->
						<xsl:text>http://dendro.dans.knaw.nl/project/</xsl:text>
						<xsl:value-of select="sid" />
					</xsl:element>
					<xsl:element name="acdm:publisher">
						<!-- DANS distributes the data via the archive? -->
						<xsl:element name="foaf:name"><xsl:text>Data Archiving and Networked Services (DANS)</xsl:text></xsl:element>
						<xsl:element name="acdm:typeOfAnAgent"><xsl:text>Organization</xsl:text></xsl:element>
						<xsl:element name="foaf:mbox"><xsl:text>info@dans.knaw.nl</xsl:text></xsl:element> 
					</xsl:element>
				</xsl:element>

			</acdm:collection>
		</acdm:ariadneArchaeologicalResource>
		</acdm:ariadne>
	</xsl:template>

	<!-- =================================================================================== -->
	<!-- convert a year (number) to a valid xs:date yyyy -->
	<!-- =================================================================================== -->
	<xsl:template name='year_to_date'>
		<xsl:param name='year' />
		<xsl:choose>
			<xsl:when test="$year=''">
				<xsl:text>2050</xsl:text><!-- in the future! -->
			</xsl:when>
			<xsl:when test="$year &lt; -9999">
				<!-- don't padd with zeros -->
				<xsl:value-of select="$year" />
			</xsl:when>
			<xsl:otherwise>        
				<xsl:value-of select="format-number($year, '0000')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- =================================================================================== -->
	<!-- construct a person agent -->
	<!-- =================================================================================== -->
	<xsl:template name='person-agent'>
		<xsl:param name='name' />
		<xsl:element name="foaf:name">
			<xsl:value-of select='$name' />
		</xsl:element>
		<xsl:element name="acdm:typeOfAnAgent">
			<xsl:text>Person</xsl:text>
		</xsl:element>
		<xsl:element name="foaf:mbox">
			<xsl:text>Not available</xsl:text>
		</xsl:element>
	</xsl:template>
	
	<!-- =================================================================================== -->
	<!-- construct a organization agent -->
	<!-- =================================================================================== -->
	<xsl:template name='organization-agent'>
		<xsl:param name='name' />
		<xsl:element name="foaf:name">
			<xsl:value-of select='$name' />
		</xsl:element>
		<xsl:element name="acdm:typeOfAnAgent">
			<xsl:text>Organization</xsl:text>
		</xsl:element>
		<xsl:element name="foaf:mbox">
			<xsl:text>Not available</xsl:text>
		</xsl:element>
	</xsl:template>
	
	<!-- =================================================================================== -->
	<!-- Would be simpler if DCCD REST API already produced the URI's -->
	<!-- =================================================================================== -->
	<dccd:categorylist>
		<dccd:category>
			<dccd:label>archaeology</dccd:label>
			<dccd:label>archeologie</dccd:label>
			<dccd:label>archäologie</dccd:label>
			<dccd:label>archéologie</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/4dcd4d86-2d96-497f-9e09-aacda714aa24
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>built heritage</dccd:label>
			<dccd:label>gebouwd erfgoed</dccd:label>
			<dccd:label>baudenkmalpflege</dccd:label>
			<dccd:label>patrimoine immobilier</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/a9ec656f-1bd3-4a30-bd5a-d012b16e496f
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>furniture</dccd:label>
			<dccd:label>meubilair</dccd:label>
			<dccd:label>möbel</dccd:label>
			<dccd:label>mobilier</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/fbd9f1b6-7933-416d-886d-6ee6d5b4d679
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>mobilia</dccd:label>
			<dccd:label>mobilia</dccd:label>
			<dccd:label>mobilia</dccd:label>
			<dccd:label>patrimoine mobilier</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/f862da84-56eb-4bf3-868a-bd92a0e75698
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>musical instrument</dccd:label>
			<dccd:label>muziek instrument</dccd:label>
			<dccd:label>musikinstrument</dccd:label>
			<dccd:label>instrument de musique</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/ce9f00c4-bdf2-4a17-93f8-4f243b8a246a
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>painting</dccd:label>
			<dccd:label>schilderij</dccd:label>
			<dccd:label>gemälde</dccd:label>
			<dccd:label>peinture</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/711a46f3-6341-4739-9084-8f5c74391d9b
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>palaeo-vegetation</dccd:label>
			<dccd:label>paleo-vegetatie</dccd:label>
			<dccd:label>paläovegetation</dccd:label>
			<dccd:label>paléo-végétation</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/75966336-9fd7-4e02-9ca8-75ae1f97236b
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>ship archaeology</dccd:label>
			<dccd:label>scheepsarcheologie</dccd:label>
			<dccd:label>schiffarchäologie</dccd:label>
			<dccd:label>archéologie navale</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/58cc5d6e-56bf-4f75-bb1e-207e206cda22
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>standing trees</dccd:label>
			<dccd:label>staande boom</dccd:label>
			<dccd:label>stehende Bäume</dccd:label>
			<dccd:label>arbre sur pied</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/cf276d9f-bf0e-47cf-a3f3-9c72372fadf0
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>woodcarving</dccd:label>
			<dccd:label>houtsnijwerk</dccd:label>
			<dccd:label>holzschnitzarbeit</dccd:label>
			<dccd:label>sculpture sur bois</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/56eac9df-7992-49d7-b614-e903636dae48
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>other</dccd:label>
			<dccd:label>anders</dccd:label>
			<dccd:label>andere</dccd:label>
			<dccd:label>autre</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/edfadf9a-4d49-413f-a893-76837af97fb5
			</dccd:uri>
		</dccd:category>
	</dccd:categorylist>
	<xsl:key name="category-lookup" match="dccd:category" use="dccd:label" />
	<xsl:variable name="categorylist-top" select="document('')/*/dccd:categorylist" />
	<xsl:template name="dccd_categoryUri">
		<xsl:param name="label" />
		<xsl:for-each select="$categorylist-top"><!-- change context to category table -->
			<xsl:value-of select="normalize-space(key('category-lookup', $label)/dccd:uri)" />
		</xsl:for-each>
	</xsl:template>

	<dccd:typelist>
		<dccd:type>
			<dccd:label>anthropology</dccd:label>
			<dccd:label>antropologie</dccd:label>
			<dccd:label>l'anthropologie</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/fc22100f-33fa-4c7c-83a0-e701f7eb983c
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>climatology</dccd:label>
			<dccd:label>klimatologie</dccd:label>
			<dccd:label>climatologie</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/86ca4a80-42bc-4aad-a228-34af2cd65325
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>dating</dccd:label>
			<dccd:label>datering</dccd:label>
			<dccd:label>datation</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/eae29d68-5880-4817-b035-a061570113fd
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>ecology</dccd:label>
			<dccd:label>ecologie</dccd:label>
			<dccd:label>écologie</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/730709ae-56db-460a-b0ce-b08f41473218
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>entomology</dccd:label>
			<dccd:label>entomologie</dccd:label>
			<dccd:label>entomologie</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/7e2dcf8d-6088-4bc2-82b1-48844cc91e7b
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>forest dynamics</dccd:label>
			<dccd:label>bosdynamiek</dccd:label>
			<dccd:label>dynamique forestrière</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/4ba2e9b8-3f10-46c0-85fe-8f6a7e4a49f7
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>forest management studies</dccd:label>
			<dccd:label>bosbeheer studies</dccd:label>
			<dccd:label>études de gestion forestière</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/85663032-0177-4716-81ae-841cad1d852f
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>forestry</dccd:label>
			<dccd:label>bosbouw</dccd:label>
			<dccd:label>foresterie</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/1b6d784a-f722-454b-8919-dd107fb49c4e
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>hydrology</dccd:label>
			<dccd:label>hydrologie</dccd:label>
			<dccd:label>hydrologie</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/3e01b25a-bb0d-4367-8359-8b2f892ff73c
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>geomorphology</dccd:label>
			<dccd:label>geomorfologie</dccd:label>
			<dccd:label>géomorphologie</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/15bc517e-0798-414a-88b8-1f362ad9df02
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>glaciology</dccd:label>
			<dccd:label>glaciologie</dccd:label>
			<dccd:label>glaciologie</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/709f582e-1700-4d28-8bc9-15e1f39e462d
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>palaeo-ecology</dccd:label>
			<dccd:label>paleo-ecologie</dccd:label>
			<dccd:label>paléo-écologie</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/52f2773b-c0dd-4794-9148-d9c0c7feeeed
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>provenancing</dccd:label>
			<dccd:label>herkomst bepaling</dccd:label>
			<dccd:label>provenance</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/99f944af-036c-4628-ae20-c8b3415a301a
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>pyrochronology</dccd:label>
			<dccd:label>pyrochronologie</dccd:label>
			<dccd:label>pyrochronologie</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/f0c7ba01-b80a-4cb7-88f8-7af442266839
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>wood technology</dccd:label>
			<dccd:label>hout technologie</dccd:label>
			<dccd:label>technologie du bois</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/c3a771df-9a22-42be-807a-bf235fce9ee3
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>wood biology</dccd:label>
			<dccd:label>hout biologie</dccd:label>
			<dccd:label>biologie du bois</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/3ea52e42-a146-4f8e-8773-80f1b946c694
			</dccd:uri>
		</dccd:type>
		<dccd:type>
			<dccd:label>other: go to project.comments</dccd:label>
			<dccd:label>anders: ga naar commentaar (project.commentaar)</dccd:label>
			<dccd:label>autre: allez à commentaires (project.comments)</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/2179fd16-3230-4493-91e3-cc26b12f8a3f
			</dccd:uri>
		</dccd:type>
	</dccd:typelist>
	<xsl:key name="type-lookup" match="dccd:type" use="dccd:label" />
	<xsl:variable name="typelist-top" select="document('')/*/dccd:typelist" />
	<xsl:template name="dccd_typeUri">
		<xsl:param name="label" />
		<xsl:for-each select="$typelist-top"><!-- change context to type table -->
			<xsl:value-of select="normalize-space(key('type-lookup', $label)/dccd:uri)" />
		</xsl:for-each>
	</xsl:template>

	<!-- In the future we would like to use skos vocabs for taxon and object/element 
		types, but these are huge! -->

</xsl:stylesheet>