<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import href="/etc/asciidoc/docbook-xsl/epub.xsl" />

	<xsl:template match='link[starts-with(@linkend, "anno-") and not(//sidebar[@id=current()/@linkend])]'>
		<xsl:for-each select="./text()|./*" >
			<xsl:apply-templates select="." />
		</xsl:for-each>
	</xsl:template>

	<!--<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*" />
		</xsl:copy>
	</xsl:template>-->
</xsl:stylesheet>
