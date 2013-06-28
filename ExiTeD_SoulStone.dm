<module>

    <!-- Information sur le module -->
    <header>
        <!-- Nom affiché dans la liste des modules -->
        <name>SoulStone</name>        
        <!-- Version du module -->
        <version>1.0</version>
        <!-- Dernière version de dofus pour laquelle ce module fonctionne -->
        <dofusVersion>2.3.5</dofusVersion>
        <!-- Auteur du module -->
        <author>ExiTeD</author>
        <!-- Courte description -->
        <shortDescription>N'oubliez plus votre pierre d'âme</shortDescription>
        <!-- Description détaillée -->
        <description>L'interface s'affiche pendant la phase de préparation du combat si il contient un Boss ou un Archi. Le module scanne les pierres d'âmes présentent en inventaire et proposent la pierre optimale (s'il y en a) de chaque tranche de réussite. Il suffit ensuite de cliquer sur le bouton pour équiper une des pierres d'âmes proposées</description>
	</header>

    <!-- Liste des interfaces du module, avec nom de l'interface, nom du fichier squelette .xml et nom de la classe script d'interface -->
    <uis>
        <ui name="soulstone" file="xml/soulstone.xml" class="ui::SoulStoneUi" />
    </uis>
    
    <script>SoulStone.swf</script>
    
</module>
