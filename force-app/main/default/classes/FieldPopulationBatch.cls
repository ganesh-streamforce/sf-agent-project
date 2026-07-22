/**
 * @class       FieldPopulationBatch
 * @description Batch Apex class to analyze field population rates across any Salesforce object.
 *              Iterates through all accessible fields, counts non-null values per field,
 *              calculates usage percentages, and exports results as a CSV ContentVersion file.
 *
 * @implements  Database.Batchable<SObject>
 *              Database.Stateful
 *
 * @usage
 *   // Basic execution (default batch size = 200)
 *   Id jobId = Database.executeBatch(new FieldPopulationBatch('Account'));
 *
 *   // Custom batch size (reduce if hitting heap limits on wide objects)
 *   Id jobId = Database.executeBatch(new FieldPopulationBatch('Account'), 50);
 *
 */
public with sharing class FieldPopulationBatch
implements Database.Batchable<SObject>, Database.Stateful {

    /** API name of the SObject to analyze */
    private String objectApiName;

    /** Ordered list of field API names to include in the analysis */
    private List<String> fieldNames;

    /** Field labels (serializable) */
    private Map<String, String> fieldLabels;

    /** Field types (serializable) */
    private Map<String, String> fieldTypes;

    /** Running count of non-null values per field across all batches */
    private Map<String, Integer> fieldPopulatedCounts;

    /** Total records processed across all execute() calls */
    private Integer totalRecordsProcessed;

    public class FieldPopulationException extends Exception {}

    public FieldPopulationBatch(String objName) {

        this.objectApiName         = objName;
        this.totalRecordsProcessed = 0;

        this.fieldNames            = new List<String>();
        this.fieldLabels           = new Map<String, String>();
        this.fieldTypes            = new Map<String, String>();
        this.fieldPopulatedCounts  = new Map<String, Integer>();

        initializeFields();
    }

    // ─── Field Initialization ─────────────────────────────────────────────────
    private void initializeFields() {

        Schema.DescribeSObjectResult objDescribe =
            Schema.getGlobalDescribe()
                .get(objectApiName)
                ?.getDescribe();

        if (objDescribe == null) {
            throw new FieldPopulationException(
                'Object not found or inaccessible: ' + objectApiName
            );
        }

        Map<String, Schema.SObjectField> fieldsMap =
            objDescribe.fields.getMap();

        for (String fieldApiName : fieldsMap.keySet()) {

            Schema.DescribeFieldResult fDesc =
                fieldsMap.get(fieldApiName).getDescribe();

            String fieldName = fDesc.getName();

            // Accessibility guard
            if (!fDesc.isAccessible()) {
                System.debug(
                    LoggingLevel.WARN,
                    'Skipping inaccessible field: ' + fieldName
                );
                continue;
            }

            Schema.DisplayType fieldType = fDesc.getType();

            fieldNames.add(fieldName);

            fieldLabels.put(fieldName, fDesc.getLabel());

            fieldTypes.put(
                fieldName,
                String.valueOf(fieldType)
            );

            fieldPopulatedCounts.put(fieldName, 0);
        }

        if (fieldNames.isEmpty()) {
            throw new FieldPopulationException(
                'No accessible fields found for: ' + objectApiName
            );
        }
    }

    // ─── Batchable Interface ──────────────────────────────────────────────────

    /**
     * @description Builds the SOQL query selecting all target fields.
     *              Uses Database.getQueryLocator for efficient cursor-based pagination.
     * @param  bc   Batchable context provided by the platform
     * @return      QueryLocator for all records of the target object
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {

        String query =
            'SELECT ' +
            String.join(fieldNames, ', ') +
            ' FROM ' +
            objectApiName;

        System.debug('Generated Query Length: ' + query.length());

        return Database.getQueryLocator(query);
    }

    /**
     * @description Processes each batch of records.
     *              Increments per-field populated counters for non-null values.
     * @param bc    Batchable context
     * @param scope Current batch of SObject records
     */
    public void execute(
        Database.BatchableContext bc,
        List<SObject> scope
    ) {

        totalRecordsProcessed += scope.size();

        for (SObject record : scope) {

            for (String fieldName : fieldNames) {

                if (record.get(fieldName) != null) {

                    fieldPopulatedCounts.put(
                        fieldName,
                        fieldPopulatedCounts.get(fieldName) + 1
                    );
                }
            }
        }
    }

    /**
     * @description Finalizes the batch run.
     *              Calculates usage percentages, generates a CSV report,
     *              and saves it as a ContentVersion (Salesforce File).
     * @param bc    Batchable context
     */
    public void finish(Database.BatchableContext bc) {

        String csv = buildCsv();

        String fileName =
            objectApiName + '_Field_Usage_Report'+ Datetime.now().format('yyyyMMdd_HHmmss');

        ContentVersion cv = new ContentVersion(
            Title          = fileName,
            PathOnClient   = fileName + '.csv',
            VersionData    = Blob.valueOf(csv),
            IsMajorVersion = true
        );

        insert cv;

        // Re-query for ContentDocumentId
        ContentVersion inserted = [
            SELECT Id, ContentDocumentId
            FROM   ContentVersion
            WHERE  Id = :cv.Id
            LIMIT  1
        ];

        String summary =
            buildSummaryLog(inserted.ContentDocumentId);

        System.debug(LoggingLevel.INFO, summary);
    }

    // ─── Reporting Helpers ────────────────────────────────────────────────────

    /**
     * @description Builds a formatted CSV string with field-level population statistics.
     * @return CSV content as String
     */
    @TestVisible
    private String buildCsv() {

        List<String> lines = new List<String>{
            'Field API Name,Field Label,Field Type,Populated Records,Total Records,Usage %'
        };

        for (String fieldName : fieldNames) {

            Integer populatedCount =
                fieldPopulatedCounts.get(fieldName);

            Decimal pct =
                totalRecordsProcessed > 0
                ? (
                    (
                        (Decimal) populatedCount /
                        totalRecordsProcessed
                    ) * 100
                ).setScale(2)
                : 0;

            String label =
                escapeCsvValue(fieldLabels.get(fieldName));

            String fieldType =
                fieldTypes.get(fieldName);

            lines.add(
                String.join(
                    new List<String>{
                        escapeCsvValue(fieldName),
                        label,
                        fieldType,
                        String.valueOf(populatedCount),
                        String.valueOf(totalRecordsProcessed),
                        pct + '%'
                    },
                    ','
                )
            );
        }

        return String.join(lines, '\n');
    }

    /**
     * @description Escapes value for safe CSV embedding.
     * @param val Raw string value
     * @return CSV-safe string
     */
    private String escapeCsvValue(String val) {

        if (val == null) {
            return '';
        }

        if (
            val.contains(',') ||
            val.contains('"') ||
            val.contains('\n')
        ) {

            return '"' +
                val.replace('"', '""') +
                '"';
        }

        return val;
    }

    /**
     * @description Produces summary log.
     * @param contentDocumentId Salesforce File ID
     * @return Summary string
     */
    private String buildSummaryLog(Id contentDocumentId) {

        Integer fieldCount      = fieldNames.size();
        Integer fullyPopulated  = 0;
        Integer emptyFields     = 0;

        for (Integer count : fieldPopulatedCounts.values()) {

            if (count == totalRecordsProcessed) {
                fullyPopulated++;
            }

            if (count == 0) {
                emptyFields++;
            }
        }

        return String.join(
            new List<String>{
                '=== FieldPopulationBatch Complete ===',
                'Object         : ' + objectApiName,
                'Total Records  : ' + totalRecordsProcessed,
                'Fields Analyzed: ' + fieldCount,
                'Fully Populated: ' + fullyPopulated,
                'Empty Fields   : ' + emptyFields,
                'Report File ID : ' + contentDocumentId,
                '====================================='
            },
            '\n'
        );
    }
}