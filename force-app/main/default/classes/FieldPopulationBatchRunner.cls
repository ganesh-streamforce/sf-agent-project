public with sharing class FieldPopulationBatchRunner {

    /**
     * @description Runs field population analysis for multiple objects.
     *              Creates one CSV file per object.
     *
     * @param objectNames List of object API names
     * @param batchSize   Optional batch size
     */
    public static void run(
        List<String> objectNames,
        Integer batchSize
    ) {

        if (objectNames == null || objectNames.isEmpty()) {
            throw new IllegalArgumentException(
                'At least one object name is required.'
            );
        }

        // Default batch size
        if (batchSize == null || batchSize <= 0) {
            batchSize = 200;
        }

        for (String objectName : objectNames) {

            try {

                System.debug(
                    LoggingLevel.INFO,
                    'Starting FieldPopulationBatch for: ' + objectName
                );

                Database.executeBatch(
                    new FieldPopulationBatch(objectName),
                    batchSize
                );

            } catch (Exception ex) {

                System.debug(
                    LoggingLevel.ERROR,
                    'Failed for object: ' +
                    objectName +
                    ' | Error: ' +
                    ex.getMessage()
                );
            }
        }
    }
}