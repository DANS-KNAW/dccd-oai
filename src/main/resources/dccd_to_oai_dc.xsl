<?xml version="1.0" encoding="UTF-8"?>
<!-- convert dccd xml (from RESTfull API) to oai_dc -->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xsl xs">

	<xsl:output indent="yes" encoding="UTF-8"
		omit-xml-declaration="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template match="text()">
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>

	<xsl:template match="/">
		<xsl:for-each select="project">
			<oai_dc:dc xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/"
				xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd http://purl.org/dc/elements/1.1/ http://dublincore.org/schemas/xmls/qdc/dc.xsd">
				<dc:date><xsl:value-of select="stateChanged" /></dc:date>
				<dc:identifier><xsl:value-of select="sid" /></dc:identifier>
				<dc:identifier><xsl:value-of select="identifier" /></dc:identifier>
				<dc:title><xsl:value-of select="title" /></dc:title>
				<dc:subject><xsl:value-of select="category" /></dc:subject>
				<!-- can have multiple -->
				<xsl:for-each select="types/type">
					<dc:subject>
						<xsl:value-of select="text()" />
					</dc:subject>
				</xsl:for-each>

				<!-- fixed static info for the DCCD archived Projects in TRiDaS -->
				<dc:subject>dendrochronology</dc:subject>
				<!-- Note: The TRiDaS description is not Open Access information 
					in DCCD -->
				<dc:description>Project</dc:description>
				<!-- Note that we have more information than in the TRiDaS, but it is the most important -->
				<dc:type><xsl:text>name=TRiDaS; URI=http://www.tridas.org</xsl:text></dc:type> 
				<dc:format><xsl:text>application/xml</xsl:text></dc:format>

				<xsl:for-each select="location">
					<dc:coverage>
						<xsl:text>φλ=</xsl:text>
						<xsl:value-of select="lat" />
						<xsl:text> </xsl:text>
						<xsl:value-of select="lng" />
						<xsl:text>; projection=http://www.opengis.net/def/crs/EPSG/0/4326; units=decimal</xsl:text>
					</dc:coverage>
				</xsl:for-each>
				<xsl:for-each select="timeRange">
					<dc:coverage>
						<xsl:text>temporalrange=</xsl:text>
						<xsl:value-of select="firstYear" />
						<xsl:text> </xsl:text>
						<xsl:value-of select="lastYear" />
						<xsl:text>; units=astronomicalyears</xsl:text>
					</dc:coverage>
				</xsl:for-each>
				<xsl:for-each select="permission">
					<dc:rights>
						<xsl:choose>
							<xsl:when test="defaultLevel/text()='minimal'">
								<xsl:text>Restricted access for all levels of detail</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>Restricted access for levels more detailed than: </xsl:text>
								<xsl:value-of select="defaultLevel" />
							</xsl:otherwise>
						</xsl:choose>
					</dc:rights>
					<xsl:for-each select="ownerOrganizationId">
						<!-- or should it be a creator -->
						<dc:publisher>
							<xsl:value-of select="text()" />
						</dc:publisher>
					</xsl:for-each>
				</xsl:for-each>
				<xsl:for-each select="taxons/taxon">
					<dc:subject>
						<xsl:value-of select="text()" />
					</dc:subject>
				</xsl:for-each>
				<xsl:for-each select="elementTypes/elementType">
					<dc:subject>
						<xsl:value-of select="text()" />
					</dc:subject>
				</xsl:for-each>
				<xsl:for-each select="objectTypes/objectType">
					<dc:subject>
						<xsl:value-of select="text()" />
					</dc:subject>
				</xsl:for-each>
				<xsl:for-each select="language">
					<dc:language>
						<xsl:value-of select="text()" />
					</dc:language>
				</xsl:for-each>
			</oai_dc:dc>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>