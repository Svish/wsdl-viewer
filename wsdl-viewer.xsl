<?xml version="1.0" encoding="UTF-8"?>
<!-- Based upon http://code.google.com/p/wsdl-viewer/ -->
<xsl:stylesheet version="2.0"
	 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	 xmlns:my="http://functions.nwn.no"
	 xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
	 xmlns:xs="http://www.w3.org/2001/XMLSchema"
	 xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
	 xmlns:wsdldoc="http://code.google.com/p/wsdldoc"
	 xmlns="http://www.w3.org/1999/xhtml"
	 extension-element-prefixes="ixsl"
	 xpath-default-namespace="">


	<xsl:output method="xml" indent="yes" encoding="utf-8" />

	
	<xsl:param name="title" />


	<xsl:template match="/">
		<!-- Change title -->
		<xsl:result-document href="#wsdl-name-title" method="ixsl:replace-content">
			<xsl:value-of select="$title" />
			<xsl:text> - WSDL Viewer</xsl:text>
		</xsl:result-document>

		<!-- Change header -->
		<xsl:result-document href="#wsdl-name-header" method="ixsl:replace-content">
			<xsl:value-of select="$title" />
		</xsl:result-document>

		<!-- Change output content -->
		<xsl:result-document href="#output" method="ixsl:replace-content">

			<xsl:apply-templates select="*/wsdl:documentation"/>

			<div id="toc"><xsl:text></xsl:text></div>
			<div id="documentation">
				<section class="operations">
					<h2>Operations</h2>
					<xsl:apply-templates select="wsdl:definitions/wsdl:portType/wsdl:operation" mode="normal">
						<xsl:sort select="@name"/>
					</xsl:apply-templates>
				</section>
				<section class="elements">
					<h2>Elements</h2>
					<xsl:apply-templates select="wsdl:definitions/wsdl:types/xs:schema/xs:element" mode="normal">
						<xsl:sort select="@name"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="wsdl:definitions/wsdl:types/xs:schema/xs:import">
						<xsl:with-param name="processType">element</xsl:with-param>
						<xsl:with-param name="mode">normal</xsl:with-param>
					</xsl:apply-templates>
				</section>
				<section class="complex-types">
					<h2>Complex Types</h2>
					<xsl:apply-templates select="wsdl:definitions/wsdl:types/xs:schema/xs:complexType" mode="normal">
						<xsl:sort select="@name"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="wsdl:definitions/wsdl:types/xs:schema/xs:import">
						<xsl:with-param name="processType">complexType</xsl:with-param>
						<xsl:with-param name="mode">normal</xsl:with-param>
					</xsl:apply-templates>
				</section>
				<section class="simple-types">
					<h2>Simple Types</h2>
					<xsl:apply-templates select="wsdl:definitions/wsdl:types/xs:schema/xs:simpleType" mode="normal">
						<xsl:sort select="@name"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="wsdl:definitions/wsdl:types/xs:schema/xs:import">
						<xsl:with-param name="processType">simpleType</xsl:with-param>
						<xsl:with-param name="mode">normal</xsl:with-param>
					</xsl:apply-templates>
				</section>
			</div>
		</xsl:result-document>
	</xsl:template>


	<!-- Normal -->


	<xsl:template match="xs:element" mode="normal">
		<div class="thing element" id="element_{@name}">
			<h3 class="normal">
				<xsl:copy-of select="my:a-ref(@name, 'element_')"/>
			</h3>
			<div class="schema"><xsl:value-of select="../@targetNamespace"/></div>

			<!-- ? -->
			<xsl:choose>
				<xsl:when test="starts-with(@name,'ArrayOf')">
					<xsl:apply-templates select="xs:complexContent/xs:restriction/xs:attribute" mode="array"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="xs:annotation/xs:documentation"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:variable name="typeName">
				<xsl:value-of select="@name"/>
			</xsl:variable>

			<dl>
				<xsl:if test="@type">
					<dt>Type</dt>
					<dd>
						<xsl:copy-of select="my:a-ref(@type, '')"/>
					</dd>
				</xsl:if>
				<xsl:apply-templates select="xs:complexContent/xs:extension" mode="extends"/>
				<xsl:if test="//xs:complexType[.//xs:extension[my:trim-prefix(@base)=$typeName]]">
					<dt>Extended by</dt>
						<xsl:apply-templates
								select="//xs:complexType[.//xs:extension[my:trim-prefix(@base)=$typeName]]"
								mode="referenced">
							<xsl:sort select="@name"/>
						</xsl:apply-templates>
				</xsl:if>
				<xsl:if test="//xs:complexType/xs:complexContent/xs:restriction/xs:attribute[my:trim-prefix(@wsdl:arrayType)=concat($typeName,'[]')]">
					<dt>Has array type</dt>
					<dd>
						<xsl:copy-of select="my:a-ref(//xs:complexType[xs:complexContent/xs:restriction/xs:attribute[my:trim-prefix(@wsdl:arrayType)=concat($typeName,'[]')]]/@name, '')"/>
					</dd>
				</xsl:if>
				<xsl:if test=".//xs:complexType/xs:complexContent/xs:extension">
					<dt>Has Complex Content</dt>
					<dd>
						<xsl:copy-of select="my:a-ref(.//xs:complexType/xs:complexContent/xs:extension/@base, '')" />
					</dd>
				</xsl:if>
				<xsl:if test="//xs:complexType[.//xs:element[my:trim-prefix(@type)=$typeName]]">
					<dt>Referenced by</dt>
					<xsl:apply-templates
							 select="//xs:complexType[.//xs:element[my:trim-prefix(@type)=$typeName]]"
							 mode="referenced">
						<xsl:sort select="@name"/>
					</xsl:apply-templates>
				</xsl:if>
				<xsl:choose>
					<!-- ? -->
					<xsl:when test="string-length(substring-before($typeName,'Exception')) = 0">
						<xsl:if test="/wsdl:definitions/wsdl:message[wsdl:part[my:trim-prefix(@type)=$typeName]]">
							<dt>Used by</dt>
							<xsl:apply-templates
									 select="/wsdl:definitions/wsdl:message[wsdl:part[my:trim-prefix(@type)=$typeName]]"
									 mode="referenced">
								<xsl:sort select="@name"/>
							</xsl:apply-templates>
						</xsl:if>
					</xsl:when>
					<!-- ? -->
					<xsl:otherwise>
						<xsl:if test="/wsdl:definitions/wsdl:portType/wsdl:operation[wsdl:fault[my:trim-prefix(@message)=$typeName]]">
							<dt>Used by</dt>
							<xsl:apply-templates
									 select="/wsdl:definitions/wsdl:portType/wsdl:operation[wsdl:fault[my:trim-prefix(@message)=$typeName]]"
									 mode="referenced">
								<xsl:sort select="@name"/>
							</xsl:apply-templates>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</dl>

			<xsl:if test=".//xs:element">
				<table>
					<thead>
						<tr>
							<th>Property name</th>
							<th>Type</th>
							<th>Required</th>
							<th>Description</th>
						</tr>
					</thead>
					<tbody>
						<xsl:apply-templates select=".//xs:element" mode="details"/>
					</tbody>
				</table>
			</xsl:if>
			<xsl:if test=".//xs:simpleType">
				<dt>Simple Type</dt>
				<ul>
					<xsl:apply-templates select=".//xs:simpleType" mode="normal">
						<xsl:sort select="@name"/>
					</xsl:apply-templates>
				</ul>
			</xsl:if>
		</div>
	</xsl:template>



	<xsl:template match="xs:simpleType" mode="normal">
		<div class="thing simpletype" id="{@name}">
			<!-- Header -->
			<h3>
				<xsl:copy-of select="my:a-ref(@name, '')" />
			</h3>
			<!-- Namespace / Schema -->
			<xsl:if test="../@targetNamespace">
				<div class="schema"><xsl:value-of select="../@targetNamespace"/></div>
			</xsl:if>

			<!-- Documentation -->
			<xsl:apply-templates select="xs:annotation/xs:documentation"/>

			<dl>
				<xsl:if test="@name">
					<xsl:variable name="typeName">
						<xsl:value-of select="my:trim-prefix(@name)"/>
					</xsl:variable>

					<!-- Referenced by -->
					<xsl:variable name="referenced_by">
						<xsl:apply-templates
								 select="//xs:element[@name and .//xs:element[my:trim-prefix(@type)=$typeName]]|//xs:complexType[@name and .//xs:element[my:trim-prefix(@type)=$typeName]]"
								 mode="referenced">
							<xsl:sort select="@name"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:if test="string($referenced_by)">
						<dt>Referenced by</dt>
						<xsl:copy-of select="$referenced_by" />
					</xsl:if>

					<!-- Used by -->
					<xsl:variable name="used_by">
						<xsl:apply-templates
								 select="/wsdl:definitions/wsdl:message[wsdl:part[my:trim-prefix(@type)=$typeName]]"
								 mode="referenced">
							<xsl:sort select="@name"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:if test="string($used_by)">
						<dt>Used by</dt>
						<xsl:copy-of select="$used_by" />
					</xsl:if>
				</xsl:if>
			</dl>

			<xsl:choose>
				<!-- Simple type is enum -->
				<xsl:when test=".//xs:enumeration">
					<table>
						<thead>
							<tr>
								<th colspan="3">Allowed enumeration values</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<th>Value</th>
								<th>Type</th>
								<th>Description</th>
							</tr>
							<xsl:apply-templates select=".//xs:enumeration" mode="details"/>
						</tbody>
					</table>
				</xsl:when>
				<!-- Other kinds-->
				<xsl:otherwise>
					<table>
						<xsl:apply-templates select="xs:restriction" mode="restriction" />
					</table>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>



	<xsl:template match="xs:complexType" mode="normal">
		<div class="thing complextype" id="{@name}">

			<!-- Header -->
			<h3 class="normal">
				<xsl:copy-of select="my:a-ref(@name, '')" />
			</h3>

			<!-- Namespace / Schema -->
			<div class="schema"><xsl:value-of select="../@targetNamespace"/></div>

			<!-- ? -->
			<xsl:choose>
				<xsl:when test="starts-with(@name,'ArrayOf')">
					<xsl:apply-templates select="xs:complexContent/xs:restriction/xs:attribute" mode="array"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="xs:annotation/xs:documentation"/>
				</xsl:otherwise>
			</xsl:choose>

			<dl>
				<!-- Extends -->
				<xsl:apply-templates select="xs:complexContent/xs:extension" mode="extends"/>

				<xsl:variable name="typeName">
					<xsl:value-of select="my:trim-prefix(@name)"/>
				</xsl:variable>
				
				<!-- Extended by -->
				<xsl:if test="../xs:complexType[.//xs:extension[my:trim-prefix(@base)=$typeName]]">
					<dt>Extended by</dt>
					<xsl:apply-templates
							select="../xs:complexType[.//xs:extension[my:trim-prefix(@base)=$typeName]]"
							mode="referenced">
						<xsl:sort select="@name"/>
					</xsl:apply-templates>
				</xsl:if>

				<!-- Has array type -->
				<xsl:if test="//xs:complexType/xs:complexContent/xs:restriction/xs:attribute[my:trim-prefix(@wsdl:arrayType)=concat($typeName,'[]')]">
					<dt>Has array type</dt>
					<dd>
						<xsl:copy-of select="my:a-ref(//xs:complexType[xs:complexContent/xs:restriction/xs:attribute[my:trim-prefix(@wsdl:arrayType)=concat($typeName,'[]')]]/@name, '')" />
					</dd>
				</xsl:if>

				<!-- Referenced by -->
				<xsl:if test="../xs:complexType[.//xs:element[my:trim-prefix(@type)=$typeName]]">
					<dt>Referenced by</dt>
					<xsl:apply-templates
							select="../xs:complexType[.//xs:element[my:trim-prefix(@type)=$typeName]]"
							mode="referenced">
						<xsl:sort select="@name"/>
					</xsl:apply-templates>
				</xsl:if>

				<!-- ? -->
				<xsl:choose>
					<xsl:when test="string-length(substring-before($typeName,'Exception')) = 0">
						<xsl:if test="/wsdl:definitions/wsdl:message[wsdl:part[my:trim-prefix(@type)=$typeName]]">
							<dt>Used by</dt>
							<xsl:apply-templates
									select="/wsdl:definitions/wsdl:message[wsdl:part[my:trim-prefix(@type)=$typeName]]"
									mode="referenced">
								<xsl:sort select="@name"/>
							</xsl:apply-templates>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="/wsdl:definitions/wsdl:portType/wsdl:operation[wsdl:fault[my:trim-prefix(@message)=$typeName]]">
							<dt>Used by</dt>
							<xsl:apply-templates
									select="/wsdl:definitions/wsdl:portType/wsdl:operation[wsdl:fault[my:trim-prefix(@message)=$typeName]]"
									mode="referenced">
								<xsl:sort select="@name"/>
							</xsl:apply-templates>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>

			</dl>
			<xsl:if test=".//xs:element">
				<table>
					<tbody>
						<tr>
							<th>Property name</th>
							<th>Type</th>
							<th>Required</th>
						</tr>
						<xsl:apply-templates select=".//xs:element" mode="details"/>
					</tbody>
				</table>
			</xsl:if>
		</div>
	</xsl:template>



	<xsl:template match="wsdl:operation" mode="normal">
		<div class="thing operation" id="operation_{@name}">
			<h3 class="normal">
				<xsl:copy-of select="my:a-ref(@name, 'operation_')" />
			</h3>
			<xsl:apply-templates select="wsdl:documentation"/>

			<xsl:variable name="opName" select="@name"/>

			<table>
				<tr>
					<th>Request</th>
					<td>
						<xsl:variable name="requestMessage">
							<xsl:value-of select="my:trim-prefix(../../wsdl:portType/wsdl:operation[@name=$opName]/wsdl:input/@message)"/>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="../../wsdl:message[@name=$requestMessage]/wsdl:part">
								<xsl:copy-of select="my:a-ref(../../wsdl:message[@name=$requestMessage]/wsdl:part/@element, 'element_')" />
							</xsl:when>
							<xsl:otherwise>
								<span class="empty">Empty</span>
							</xsl:otherwise>
						</xsl:choose>
					</td>
				</tr>
				<tr>
					<th>Response</th>
					<td>
						<xsl:variable name="responseMessage">
							<xsl:value-of
									select="my:trim-prefix(../../wsdl:portType/wsdl:operation[@name=$opName]/wsdl:output/@message)"/>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="../../wsdl:message[@name=$responseMessage]/wsdl:part">
								<xsl:copy-of select="my:a-ref(../../wsdl:message[@name=$responseMessage]/wsdl:part/@element, 'element_')" />
							</xsl:when>
							<xsl:otherwise>
								<span class="empty">Empty</span>
							</xsl:otherwise>
						</xsl:choose>
					</td>
				</tr>
				<xsl:if test="wsdl:fault">
				<tr>
					<th>Faults</th>
					<td>
						<dl>
							<xsl:apply-templates select="wsdl:fault" mode="details">
								<xsl:sort select="@name"/>
							</xsl:apply-templates>
						</dl>
					</td>
				</tr>
				</xsl:if>
			</table>
		</div>
	</xsl:template>


	<xsl:template match="wsdl:message" mode="normal">
		<table>
			<tbody>
				<tr>
					<th>Parameter name</th>
					<th>Type</th>
					<th>Element</th>
					<th>M</th>
					<th>Constraints</th>
					<th>Description</th>
				</tr>
				<xsl:apply-templates select="wsdl:part" mode="details"/>
			</tbody>
		</table>
	</xsl:template>


	<!-- Referenced -->


	<xsl:template match="wsdl:message" mode="referenced">
		<dd>
			<xsl:copy-of select="my:a-ref(replace(@name, '(Request|Response)$', ''), 'operation_')" />
		</dd>
	</xsl:template>


	<xsl:template match="wsdl:operation" mode="referenced">
		<dd>
			<xsl:copy-of select="my:a-ref(@name, 'operation_')" />
		</dd>
	</xsl:template>


	<xsl:template match="xs:complexType" mode="referenced">
		<dd>
			<xsl:copy-of select="my:a-ref(@name, '')" />
		</dd>
	</xsl:template>


	<xsl:template match="xs:element" mode="referenced">
		<dd>
			<xsl:copy-of select="my:a-ref(@name, 'element_')" />
		</dd>
	</xsl:template>


	<!-- Array -->


	<xsl:template match="xs:attribute" mode="array">
		<xsl:text>Array of</xsl:text>
		<xsl:variable name="nameWithoutArray">
			<xsl:value-of select="substring-before(@wsdl:arrayType, '[]')"/>
		</xsl:variable>
		<xsl:copy-of select="my:a-ref($nameWithoutArray, 'operation_')" />
	</xsl:template>


	<!-- Extends -->


	<xsl:template match="xs:extension" mode="extends">
		<dt>Extends</dt>
		<dd>
			<xsl:copy-of select="my:a-ref(@base, '')" />
		</dd>
	</xsl:template>


	<!-- Details -->


	<xsl:template match="xs:element" mode="details">
		<xsl:element name="tr">
			<td>
				<xsl:value-of select="if(@name) then @name else my:trim-prefix(@ref)"/>
			</td>
			<td>
				<xsl:if test="@maxOccurs = 'unbounded' or @maxOccurs != 1">
					<xsl:text>List of </xsl:text>
				</xsl:if>
				<xsl:variable name="type" select="if(xs:simpleType/xs:restriction/@base) then xs:simpleType/xs:restriction/@base else @type" />
				<xsl:copy-of select="my:a-ref($type, '')" />
			</td>
			<td>
				<xsl:value-of select="if(@nillable='true' or @minOccurs=0) then 'No' else 'Yes'" />
			</td>
			<xsl:if test="xs:annotation">
				<td>
					<xsl:apply-templates select="xs:annotation/xs:documentation" />
				</td>
			</xsl:if>
		</xsl:element>
	</xsl:template>


	<xsl:template match="xs:enumeration" mode="details">
		<tr>
			<td>
				<xsl:choose>
					<xsl:when test="string-length(@value) = 0">
						<span class="empty">Blank</span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@value"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:value-of select="../@base"/>
			</td>
			<td>
				<xsl:apply-templates select="xs:annotation/xs:documentation"/>
			</td>
		</tr>
	</xsl:template>


	<xsl:template match="wsdl:part" mode="details">
		<xsl:variable name="nameWithoutNS">
			<xsl:value-of select="my:trim-prefix(@type)"/>
		</xsl:variable>
		<xsl:variable name="elementNameWithoutNS">
			<xsl:value-of select="my:trim-prefix(@element)"/>
		</xsl:variable>
		<xsl:element name="tr">
			<xsl:attribute name="class">normal</xsl:attribute>
			<td>
				<xsl:value-of select="@name"/>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="starts-with(@type,'xs:')">
						<xsl:value-of select="@type"/>
					</xsl:when>
					<xsl:otherwise>
						<a href="#{$nameWithoutNS}">
							<xsl:value-of select="$nameWithoutNS"/>
						</a>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:copy-of select="my:a-ref($elementNameWithoutNS, 'element_')" />
			</td>
			<td>Yes</td>
			<td>
				<xsl:apply-templates select="wsdl:documentation"/>
			</td>
		</xsl:element>
	</xsl:template>


	<xsl:template match="wsdl:fault" mode="details">
		<dt>
			<xsl:variable name="nameWithoutNS">
				<xsl:value-of select="my:trim-prefix(@message)"/>
			</xsl:variable>
			<xsl:variable name="elementWithNS">
				<xsl:value-of select="//wsdl:message[@name=$nameWithoutNS]/wsdl:part/@element"/>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$elementWithNS">
					<xsl:variable name="elementWithoutNS">
						<xsl:value-of select="my:trim-prefix($elementWithNS)"/>
					</xsl:variable>
					<a href="#element_{$elementWithoutNS}">
						<xsl:value-of select="@name"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<a href="#{$nameWithoutNS}">
						<xsl:value-of select="@name"/>
					</a>
				</xsl:otherwise>
			</xsl:choose>
		</dt>
		<dd>
			<xsl:apply-templates select="wsdl:documentation"/>
		</dd>
	</xsl:template>


	<xsl:template match="xs:import">
		<xsl:param name="processType"/>
		<xsl:param name="mode"/>
		<xsl:variable name="importedxsd" select="document(@schemaLocation)"/>
		<xsl:choose>
			<xsl:when test="$processType = 'complexType'">
				<xsl:choose>
					<xsl:when test="$mode = 'TOC' ">
						<xsl:apply-templates select="$importedxsd/xs:schema/xs:complexType" mode="TOC"/>
					</xsl:when>
					<xsl:when test="$mode = 'normal' ">
						<xsl:apply-templates select="$importedxsd/xs:schema/xs:complexType" mode="normal"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$processType = 'simpleType'">
				<xsl:choose>
					<xsl:when test="$mode = 'TOC' ">
						<xsl:apply-templates select="$importedxsd/xs:schema/xs:simpleType" mode="TOC"/>
					</xsl:when>
					<xsl:when test="$mode = 'normal' ">
						<xsl:apply-templates select="$importedxsd/xs:schema/xs:simpleType" mode="normal"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$processType = 'element'">
				<xsl:choose>
					<xsl:when test="$mode = 'TOC' ">
						<xsl:apply-templates select="$importedxsd/xs:schema/xs:element" mode="TOC"/>
					</xsl:when>
					<xsl:when test="$mode = 'normal' ">
						<xsl:apply-templates select="$importedxsd/xs:schema/xs:element" mode="normal"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>



	<xsl:template match="wsdl:documentation|xs:annotation/xs:documentation">
		<p><xsl:value-of select="text()"/></p>
	</xsl:template>


	<!-- Restriction -->


	<xsl:template match="xs:restriction" mode="restriction">
		<xsl:apply-templates select="@base|*" mode="restriction" />
	</xsl:template>

	<xsl:template match="*" mode="restriction">
		<tr>
			<th><xsl:value-of select="my:fix-name(local-name())" /></th>
			<td><xsl:value-of select="@value"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="@base" mode="restriction">
		<tr>
			<th>Base type</th>
			<td><xsl:copy-of select="my:a-ref(., '')"/></td>
		</tr>
	</xsl:template>


	<!-- Functions -->


	<xsl:function name="my:trim-prefix">
		<xsl:param name="subject" />
		<xsl:value-of select="replace($subject, '^(\w+:)?(.+)', '$2')" />
	</xsl:function>

	<xsl:function name="my:upper-first">
		<xsl:param name="subject" />
		<xsl:value-of select="concat(upper-case(substring($subject, 1, 1)), substring($subject, 2))" />
	</xsl:function>

	<xsl:function name="my:fix-name">
		<xsl:param name="subject" />
		<xsl:value-of select="my:upper-first(lower-case(replace($subject, '([a-z])([A-Z])', '$1 $2')))" />
	</xsl:function>

	<xsl:function name="my:a-ref">
		<xsl:param name="name" />
		<xsl:param name="type" />
		<xsl:choose>
			<xsl:when test="starts-with($name, 'xs:') or starts-with($name, 'xsd:')">
				<xsl:value-of select="$name"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="nameWithoutPrefix" select="my:trim-prefix($name)" />
				<a href="#{$type}{$nameWithoutPrefix}">
					<xsl:value-of select="$nameWithoutPrefix"/>
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>
