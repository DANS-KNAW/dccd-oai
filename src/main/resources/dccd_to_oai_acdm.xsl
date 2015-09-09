<?xml version="1.0" encoding="UTF-8"?>
<!-- convert dccd xml (from RESTfull API) to ARIADNE acdm -->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:dccd="dccd.lookup" exclude-result-prefixes="xsl xs dccd">

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
		<!-- <xsl:result-document href="acdm_out.xml"> just make oxygen happy! -->
		<xsl:apply-templates select="project" />
		<!-- </xsl:result-document> just make oxygen happy! -->
	</xsl:template>

	<xsl:template match="project">
		<acdm:dataResource xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xmlns:acdm="http://ariadne-registry.dcu.gr/schema-definition"
			xmlns:dcat="http://www.w3.org/ns/dcat#" xmlns:dcterms="http://purl.org/dc/terms/"
			xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xsi:schemaLocation="http://ariadne-registry.dcu.gr/schema-definition http://ariadne-registry.dcu.gr/schema-definition/sample_ariadne_xml.xsd">

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
					<xsl:attribute name="preferred">true</xsl:attribute>
					<xsl:value-of select="text()" />
				</xsl:element>
			</xsl:for-each>
			<!-- TRiDaS project identifier -->
			<xsl:element name="acdm:originalId">
				<xsl:attribute name="preferred">false</xsl:attribute>
				<xsl:value-of select="identifier" />
			</xsl:element>

			<!-- LANDING PAGE -->
			<!-- use DCCD identifier -->
			<xsl:for-each select="sid">
				<xsl:element name="dcat:landingPage">
					<xsl:text>http://dendro.dans.knaw.nl/project/</xsl:text>
					<xsl:value-of select="text()" />
				</xsl:element>
			</xsl:for-each>

			<!-- PUBLISHER -->
			<!-- <xsl:for-each select=""> <xsl:element name="dcterms:publisher"> <xsl:value-of 
				select="text()" /> </xsl:element> </xsl:for-each> -->

			<!-- acdm:scientificResponsible, could be laboratory leader -->
			<!-- acdm:technicalResponsible, could be analyst -->

			<!-- OWNER -->
			<!-- This should indicate an Agent, but we can't guarantee uniquenes -->
			<xsl:for-each select="ownerOrganizationId">
				<xsl:element name="acdm:owner">
					<xsl:value-of select="text()" />
				</xsl:element>
			</xsl:for-each>

			<!-- Not using (creator, legalResponsible) -->

			<!-- LANGUAGE -->
			<xsl:for-each select="language">
				<xsl:element name="dcterms:language">
					<xsl:value-of select="text()" />
				</xsl:element>
			</xsl:for-each>

			<xsl:element name="dcterms:isPartOf">
				<xsl:text>DCCD</xsl:text>
			</xsl:element>

			<!-- archaeologicalResourceType previously ARIADNESUBJECT -->
			<xsl:element name="acdm:archaeologicalResourceType">
				<xsl:text>Scientific databases</xsl:text>
			</xsl:element>
			<!-- <dc:type><xsl:text>name=TRiDaS; URI=http://www.tridas.org</xsl:text></dc:type> 
				<dc:format>application/xml</dc:format> -->

			<!-- RIGHTS -->
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

			<!-- SUBJECT -->
			<!-- <xsl:element name="dcterms:subject"> <xsl:value-of select="category" 
				/> </xsl:element> -->
			<xsl:for-each select="category">
				<!-- use uri, reference to vocabulary in SKOS -->
				<xsl:element name="acdm:nativeSubject">
					<xsl:element name="skos:Concept">
						<xsl:attribute name="rdf:about">
							<xsl:call-template
							name="dccd_categoryUri">
								<xsl:with-param name="label"
							select="text()" />
							</xsl:call-template>
						</xsl:attribute>
						<!-- Also use human readable text -->
						<xsl:element name="skos:prefLabel">
							<xsl:value-of select="text()" />
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>

			<!-- <xsl:for-each select="types/type"> <xsl:element name="dcterms:subject"><xsl:value-of 
				select="text()" /></xsl:element> </xsl:for-each> -->
			<xsl:for-each select="types/type">
				<!-- use uri, reference to vocabulary in SKOS -->
				<xsl:element name="acdm:nativeSubject">
					<xsl:element name="skos:Concept">
						<xsl:attribute name="rdf:about">
							<xsl:call-template
							name="dccd_typeUri">
								<xsl:with-param name="label"
							select="text()" />
							</xsl:call-template>
						</xsl:attribute>
						<!-- Also use human readable text -->
						<xsl:element name="skos:prefLabel">
							<xsl:value-of select="text()" />
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>

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

			<!-- SPATIAL -->
			<xsl:for-each select="location">
				<!-- point -->
				<xsl:element name="acdm:spatial">
					<xsl:element name="acdm:lat">
						<xsl:value-of select="lat" />
					</xsl:element>
					<xsl:element name="acdm:lon">
						<xsl:value-of select="lng" />
					</xsl:element>
					<xsl:element name="acdm:coordinateSystem">
						<xsl:text>http://www.opengis.net/def/crs/EPSG/0/4326</xsl:text>
					</xsl:element>
					<xsl:element name="acdm:placeName">
						<xsl:text>Not available</xsl:text>
					</xsl:element>
					<xsl:element name="acdm:country">
						<xsl:text>Not available</xsl:text>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>

			<!-- TEMPORAL -->
			<xsl:for-each select="timeRange">
				<xsl:element name="acdm:temporal">
					<xsl:element name="acdm:from">
						<xsl:value-of select="firstYear" />
					</xsl:element>
					<xsl:element name="acdm:to">
						<xsl:value-of select="lastYear" />
					</xsl:element>
					<xsl:element name="acdm:periodName">
						<xsl:text>Not available</xsl:text>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>

		</acdm:dataResource>
	</xsl:template>

	<!-- =================================================================================== -->
	<!-- Would be simpler if DCCD REST API already produced the URI's -->
	<dccd:categorylist>
		<dccd:category>
			<dccd:label>archaeology</dccd:label>
			<dccd:label>archeologie</dccd:label>
			<dccd:label>Archäologie</dccd:label>
			<dccd:label>archéologie</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/4dcd4d86-2d96-497f-9e09-aacda714aa24
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>built heritage</dccd:label>
			<dccd:label>gebouwd erfgoed</dccd:label>
			<dccd:label>Baudenkmalpflege</dccd:label>
			<dccd:label>patrimoine immobilier</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/a9ec656f-1bd3-4a30-bd5a-d012b16e496f
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>furniture</dccd:label>
			<dccd:label>meubilair</dccd:label>
			<dccd:label>Möbel</dccd:label>
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
			<dccd:label>Musikinstrument</dccd:label>
			<dccd:label>instrument de musique</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/ce9f00c4-bdf2-4a17-93f8-4f243b8a246a
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>painting</dccd:label>
			<dccd:label>schilderij</dccd:label>
			<dccd:label>Gemälde</dccd:label>
			<dccd:label>peinture</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/711a46f3-6341-4739-9084-8f5c74391d9b
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>palaeo-vegetation</dccd:label>
			<dccd:label>paleo-vegetatie</dccd:label>
			<dccd:label>Paläovegetation</dccd:label>
			<dccd:label>paléo-végétation</dccd:label>
			<dccd:uri>http://dendro.dans.knaw.nl/dccd-terms/75966336-9fd7-4e02-9ca8-75ae1f97236b
			</dccd:uri>
		</dccd:category>
		<dccd:category>
			<dccd:label>ship archaeology</dccd:label>
			<dccd:label>scheepsarcheologie</dccd:label>
			<dccd:label>Schiffarchäologie</dccd:label>
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
			<dccd:label>Holzschnitzarbeit</dccd:label>
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