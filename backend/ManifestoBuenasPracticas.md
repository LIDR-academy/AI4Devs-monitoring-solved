# EN
# **LTI Project Good Practice Guide EN**

## **1. Domain-Driven Design (DDD)**

**Domain-Driven Design (DDD)** is a methodology that focuses on modeling software based on business logic and the domain. By centering development on a deep understanding of the domain, DDD facilitates the creation of complex systems.
**Advantages:**

- **Improves communication:** Promotes a common language between developers and domain experts, improving communication and reducing interpretation errors.
- **Clear domain models:** Helps build models that accurately reflect business rules and processes.
- **High maintainability:** By dividing the system into subdomains, it facilitates software maintenance and evolution.

**Key Components:**

- **Entities:** Objects with a distinctive identity.
    
    *Before*
    
    ```tsx
    // Anteriormente, los datos del candidato podrían haber sido manejados como un simple objeto JSON sin métodos.
    const candidate = {
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com'
    };
    ```
    
    *After*
    
    ```tsx
    export class Candidate {
        id?: number;
        firstName: string;
        lastName: string;
        email: string;
        // Constructor y métodos que encapsulan la lógica de negocio.
        constructor(data: any) {
            this.id = data.id;
            this.firstName = data.firstName;
            this.lastName = data.lastName;
            this.email = data.email;
        }
    }
    ```
    
    <aside>
    💡 **Explanation**: `Candidate` is an entity because it has a unique identifier (**id**) that distinguishes it from other candidates, even if other properties are identical.
    
    </aside>
    
- **Value Objects:** Objects that describe aspects of the domain without conceptual identity.
    
    *Before*
    
    ```tsx
     // Manejo de información de educación como un simple objeto.
    const education = {
        institution: 'University',
        degree: 'Bachelor',
        startDate: '2010-01-01',
        endDate: '2014-01-01'
    };
    ```
    
    *After*
    
    ```tsx
    export class Education {
        institution: string;
        title: string;
        startDate: Date;
        endDate?: Date;
        constructor(data: any) {
            this.institution = data.institution;
            this.title = data.title;
            this.startDate = new Date(data.startDate);
            this.endDate = data.endDate ? new Date(data.endDate) : undefined;
        }
    }
    ```
    
    <aside>
    💡 **Explanation**: `Education` can be considered a **Value Object** in some contexts, as it describes a candidate's education without needing a unique identifier to define it. However, in this model, it has been assigned an id, which might contradict the pure definition of a Value Object in DDD.
    
    **Clarification and Correct Use of Value Objects**
    
    Currently, some classes such as `Education` and `WorkExperience` have unique identifiers, which classifies them as entities. However, in many cases, these could be treated as Value Objects within the context of a Candidate.
    
    **Proposed Improvement:**
    
    -Remove unique identifiers from classes that should be Value Objects. This involves changing the way these classes are handled in the database, possibly by incorporating them as part of the Candidate documents if using a NoSQL database, or by keeping them in separate tables but not treating them as separate entities in the domain.
    </aside>
    
    *Improved version*
    
    ```tsx
    
    ```
    
- **Added:** Sets of objects that should be treated as a unit.
    
    *Before*
    
    ```tsx
     // Datos del candidato y su educación manejados por separado.
    const candidate = { id: 1, name: 'John Doe' };
    const educations = [{ candidateId: 1, institution: 'University' }];
    ```
    
    *After*
    
    ```tsx
    export class Candidate {
        id?: number;
        firstName: string;
        lastName: string;
        email: string;
        educations: Education[];
        constructor(data: any) {
            this.id = data.id;
            this.firstName = data.firstName;
            this.lastName = data.lastName;
            this.email = data.email;
            this.educations = data.educations.map(edu => new Education(edu));
        }
    }
    ```
    
    <aside>
    💡 **Explanation**: `Candidate` acts as an aggregate containing `Education`, `WorkExperience`, `Resume`, and `Application`. `Candidate` is the root of the aggregate, since the other entities only make sense in relation to a candidate.
    
    **Recommendation:** Aggregates must be carefully designed to ensure that all operations within the aggregate boundary maintain consistency.
    
   **Proposed Improvement:**
    
    - Review and possibly limit operations that modify objects within the `Candidate` aggregate. For example, operations affecting `Education` and `WorkExperience` should be handled through the aggregate root, `Candidate`, to maintain integrity and encapsulation.

    </aside>
    
    *Improved version*
    
    ```tsx
    
    ```
    
- **Repositories:** Interfaces that provide access to aggregates and entities.
    
    *Before*
    
    ```tsx
    // Acceso directo a la base de datos sin abstracción.
    function getCandidateById(id) {
        return database.query('SELECT * FROM candidates WHERE id = ?', [id]);
    }
    ```
    
    Explanation:
    
    *After*
    
    ```tsx
    export class CandidateRepository {
        async findById(id: number): Promise<Candidate | null> {
            const data = await prisma.candidate.findUnique({ where: { id } });
            return data ? new Candidate(data) : null;
        }
    }
    ```
    
    <aside>
    💡 **Explanation**: `CandidateRepository` provides a clear interface for accessing candidate data, encapsulating the database access logic.
    
    **Recommendation:** The repositories are partially implemented but could be extended to fully encapsulate all data access operations related to their entities.
    
    **Proposed Improvement:**
    
    - Develop comprehensive repository interfaces for each entity and aggregate, ensuring that all database interactions for those entities go through the repository. This could include methods for creating, updating, deleting, and searching for entities.
    - Implement repository methods that handle collections of entities, such as Candidate lists, that can be filtered or modified in bulk.
    </aside>
    
- **Domain Services:** Business logic that does not naturally belong to an entity or value.
    
    *Before*
    
    ```tsx
    // Funciones sueltas para manejar la lógica de negocio.
    function calculateAge(candidate) {
        const today = new Date();
        const birthDate = new Date(candidate.birthDate);
        let age = today.getFullYear() - birthDate.getFullYear();
        const m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }
        return age;
    }
    ```
    
    *After*
    
    ```tsx
    export class CandidateService {
      static calculateAge(candidate: Candidate): number {
          const today = new Date();
          const birthDate = new Date(candidate.birthDate);
          let age = today.getFullYear() - birthDate.getFullYear();
          const m = today.getMonth() - birthDate.getMonth();
          if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
              age--;
          }
          return age;
      }
    }
    ```
    
    <aside>
    💡 **Explanation**: `CandidateService` encapsulates candidate-related business logic, such as calculating age, providing a centralized and consistent point for handling these operations.
    
    </aside>
    
- **Other recommendations**
    
    **Using Factories**
    
    Factories are useful in DDD for encapsulating complex object creation logic, ensuring that all created objects comply with domain rules from the moment they are created.
    
    <aside>
    💡 **Proposed Improvement:** Implement factories for the creation of entities and aggregates, especially those that are complex and require a specific initial configuration that complies with business rules.
    
    </aside>
    
    **Improved Relationship Modeling**
    
    Relationships between entities and aggregates must be clear and consistent with business rules.
    
    <aside>
    💡 **Proposed Enhancement:** Review and possibly redesign entity relationships to ensure they accurately reflect the domain's needs and rules. This may include removing unnecessary relationships or adding new ones that facilitate business operations.
    
    </aside>
    
    **Domain Event Integration**
    
    Domain events are an important part of DDD and can be used to handle side effects of domain operations in a decoupled manner.
    
    <aside>
    💡 **Proposed Enhancement:** Implement a domain event system that allows entities and aggregates to publish events that other system components can handle without being tightly coupled to the entities that generate them.
    
    </aside>
    

## **2. SOLID and DRY principles**

**SOLID**

The SOLID principles are five object-oriented design principles that help create more understandable, flexible, and maintainable systems.

- **S - Single Responsibility Principle (SRP):** Each class should have a single responsibility or reason for changing.
    
    *Before*
    
    ```tsx
    // Un método que maneja múltiples responsabilidades: validación y almacenamiento de datos.
    function processCandidate(candidate) {
        if (!candidate.email.includes('@')) {
            console.error('Email inválido');
            return;
        }
        database.save(candidate);
        console.log('Candidato guardado');
    }
    ```
    
    *After*
    
    ```tsx
    export class Candidate {
      // La clase ahora solo se encarga de la lógica relacionada con el candidato.
      validateEmail() {
          if (!this.email.includes('@')) {
              throw new Error('Email inválido');
          }
      }
    
      save() {
          this.validateEmail();
          prisma.candidate.create(this);
      }
    }
    ```
    
    <aside>
    💡 **Explanation**: The `Candidate` class now has separate methods for validating the email and saving the information, complying with the single responsibility principle.
    
   **Observation:**
    
    The Candidate class in `backend/src/domain/models/Candidate.ts` handles both the business logic and data access logic.
    
    **Recommendation:**
    
    Separate data access logic into a repository layer to adhere more closely to SRP.
    
    </aside>
    
    *Improvement Example:*
    
    Create a `CandidateRepository` class for database interactions.
    
    ```
    class CandidateRepository {
        async save(candidateData: any) {
            // Database interaction logic here
        }
    }
    ```
    
- **O - Open/Closed Principle (OCP):** Software entities should be open for extension, but closed for modification.
    
    *Before*
    
    ```tsx
    // Modificación directa de la clase para añadir funcionalidad.
    class Candidate {
        saveToDatabase() {
            // código para guardar en la base de datos
        }
        // Para añadir nueva funcionalidad, modificamos la clase directamente.
        sendEmail() {
            // código para enviar un email
        }
    }
    ```
    
    *After*
    
    ```tsx
    export class Candidate {
      saveToDatabase() {
          // código para guardar en la base de datos
      }
    }
    // Extendemos la funcionalidad sin modificar la clase existente.
    class CandidateWithEmail extends Candidate {
      sendEmail() {
          // código para enviar un email
      }
    }
    ```
    
    <aside>
    💡 **Explanation**: The functionality of sending an email is extended in a subclass, keeping the original class closed to modification but open to extensions.
    
    **Observation:**
    
    The `addCandidate` function in `backend/src/application/services/candidateService.ts` directly instantiates `Candidate`, `Education`, `WorkExperience`, and `Resume` classes.
    
    **Recommendation:**
    
    Use factory methods to create instances, allowing for easier extension without modifying existing code.
    
    </aside>
    
    *Improvement Example:*
    
    Implement a factory method for creating a Candidate.
    
    ```tsx
    class CandidateFactory {
        static createCandidate(data: any): Candidate {
            return new Candidate(data);
        }
    }
    ```
    
- **L - Liskov Substitution Principle (LSP):** Objects of a derived class must be replaceable by objects of the base class without altering the operation of the program.
    
    *Before*
    
    ```tsx
    // Subclase que no puede reemplazar completamente a su clase base.
    class TemporaryCandidate extends Candidate {
        saveToDatabase() {
            throw new Error("Temporary candidates can't be saved.");
        }
    }
    ```
    
    *After*
    
    ```tsx
    class TemporaryCandidate extends Candidate {
      saveToDatabase() {
          // Implementación adecuada que permite guardar o manejar temporalmente.
          console.log("Handled temporarily");
      }
    }
    ```
    
    <aside>
    💡 **Explanation**: `TemporaryCandidate` now provides a proper implementation that respects the base class contract, allowing for error-free overriding.
    
    **Observation:**
    
    Currently, there is no inheritance in use where LSP could be violated. The project uses composition over inheritance, which generally supports LSP.
    
    **Recommendation:**
    
    Continue using composition to avoid LSP violations and ensure that any future inheritance structures allow derived classes to substitute their base classes without altering how the program works.
    
    </aside>
    
- **I - Interface Segregation Principle (ISP):** Many specific interfaces are better than a single general interface.
    
    *Before*
    
    ```tsx
    // Una interfaz grande que los clientes pequeños no usan completamente.
    interface CandidateOperations {
        save();
        validate();
        sendEmail();
        generateReport();
    }
    ```
    
    *After*
    
    ```tsx
    interface SaveOperation {
        save();
    }
    
    interface EmailOperations {
        sendEmail();
    }
    
    interface ReportOperations {
        generateReport();
    }
    
    class Candidate implements SaveOperation, EmailOperations {
        save() {
            // implementación
        }
    
        sendEmail() {
            // implementación
        }
    }
    ```
    
    <aside>
    💡 **Explanation**: Interfaces are segregated into smaller operations, allowing classes to implement only the interfaces they need.
    
    **Observation:**
    
    The project does not currently use TypeScript interfaces extensively to enforce contracts for classes.
    
    **Recommendation:**
    
    Define more granular interfaces for service classes to ensure they only implement the methods they need.
    
    </aside>
    
    *Improvement Example:*
    
    Define an interface for candidate-related operations.
    
    ```tsx
    interface ICandidateService {
        addCandidate(candidateData: any): Promise<Candidate>;
        findCandidateById(id: number): Promise<Candidate | null>;
    }
    ```
    
- **D - Dependency Inversion Principle (DIP):** High-level modules should not depend on low-level modules; both should depend on abstractions.
    
    *Before*
    
    ```tsx
    // Dependencia directa de una implementación concreta.
    class Candidate {
               private database = new MySQLDatabase();
        save() {
            this.database.save(this);
        }
    }
    ```
    
    *After*
    
    ```tsx
    interface Database {
        save(candidate: Candidate);
    }
    
    class Candidate {
        private database: Database;
        constructor(database: Database) {
            this.database = database;
        }
    
        save() {
            this.database.save(this);
        }
    }
    ```
    
    <aside>
    💡 **Explanation**: `Candidate` now depends on an abstraction (Database), not a concrete implementation, which makes code more flexible and testable.
    
    **Observation:**
    
    Classes like Candidate directly depend on the concrete PrismaClient for database operations.
    
    **Recommendation:**
    
    Use dependency injection to invert the dependency, relying on abstractions rather than concrete implementations.
    
    </aside>
    
    *Improvement Example:*
    
    Inject `PrismaClient` through the constructor or a setter method.
    
    ```tsx
    constructor(data: any, private prismaClient: PrismaClient) {
        // Initialization code
    }
    ```
    

**DRY (Don't Repeat Yourself)**

The DRY principle focuses on reducing duplication in code. Each piece of knowledge should have a unique, unambiguous, and authoritative representation within a system.

*Before*

```tsx
// Código repetido para validar emails en múltiples funciones.
function saveCandidate(candidate) {
    if (!candidate.email.includes('@')) {
        throw new Error('Email inválido');
    }
    // guardar lógica
}

function updateCandidate(candidate) {
    if (!candidate.email.includes('@')) {
        throw new Error('Email inválido');
    }
    // actualizar lógica
}
```

*After*

```tsx
export class Candidate {
    validateEmail() {
        if (!this.email.includes('@')) {
            throw new Error('Email inválido');
        }
    }

    save() {
        this.validateEmail();
        // guardar lógica
    }

    update() {
        this.validateEmail();
        // actualizar lógica
    }
}
```

<aside>
💡 **Explanation**: Email validation is centralized in a single `validateEmail` method, eliminating code duplication in the save and update functions.

**Observation:**

The methods for saving entities like `Candidate`, `Education`, `WorkExperience`, and `Resume` contain repetitive logic for handling database operations.

**Recommendation:**

Abstract common database operation logic into a reusable function or class.

</aside>

Improvement Example:

Create a generic database handler.

```tsx
class DatabaseHandler {
    static async saveEntity(entity: any) {
        // Generic save logic
    }
}
```

[**Design Patterns**](https://www.notion.so/Patrones-de-Dise-o-e006deb558f34f259a68b509f67566c7?pvs=21)

[Prompt: Good Practices Manifesto](https://www.notion.so/Prompt-Manifesto-Buenas-Pr-cticas-ff4938d307174a4bbdcfc5fd2dbbbe6d?pvs=21)

[Good Practices Contract](https://www.notion.so/Contrato-Buenas-Pr-cticas-dd592dd96989406eb226bb240e495f27?pvs=21)

# ES
# **Guía de Buenas Prácticas Proyecto LTI**

## **1. Domain-Driven Design (DDD)**

El **Diseño Guiado por el Dominio (DDD)** es una metodología que se enfoca en modelar el software según la lógica del negocio y el dominio. Al centrar el desarrollo en una comprensión profunda del dominio, DDD facilita la creación de sistemas complejos.

**Ventajas:**

- **Mejora la comunicación:** Promueve un lenguaje común entre desarrolladores y expertos en el dominio, mejorando la comunicación y reduciendo errores de interpretación.
- **Modelos de dominio claros:** Ayuda a construir modelos que reflejan fielmente las reglas y procesos del negocio.
- **Alta mantenibilidad:** Al dividir el sistema en subdominios, facilita el mantenimiento y la evolución del software.

**Componentes Clave:**

- **Entidades:** Objetos con identidad distintiva.
    
    *Antes*
    
    ```tsx
    // Anteriormente, los datos del candidato podrían haber sido manejados como un simple objeto JSON sin métodos.
    const candidate = {
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com'
    };
    ```
    
    *Después*
    
    ```tsx
    export class Candidate {
        id?: number;
        firstName: string;
        lastName: string;
        email: string;
        // Constructor y métodos que encapsulan la lógica de negocio.
        constructor(data: any) {
            this.id = data.id;
            this.firstName = data.firstName;
            this.lastName = data.lastName;
            this.email = data.email;
        }
    }
    ```
    
    <aside>
    💡 **Explicación**: `Candidate` es una entidad ya que tiene un identificador único (**id**) que lo distingue de otros candidatos, incluso si otras propiedades son idénticas.
    
    </aside>
    
- **Value Objects:** Objetos que describen aspectos del dominio sin identidad conceptual.
    
    *Antes*
    
    ```tsx
     // Manejo de información de educación como un simple objeto.
    const education = {
        institution: 'University',
        degree: 'Bachelor',
        startDate: '2010-01-01',
        endDate: '2014-01-01'
    };
    ```
    
    *Después*
    
    ```tsx
    export class Education {
        institution: string;
        title: string;
        startDate: Date;
        endDate?: Date;
        constructor(data: any) {
            this.institution = data.institution;
            this.title = data.title;
            this.startDate = new Date(data.startDate);
            this.endDate = data.endDate ? new Date(data.endDate) : undefined;
        }
    }
    ```
    
    <aside>
    💡 **Explicación**: `Education` puede considerarse un **Value Object** en algunos contextos, ya que describe la educación de un candidato sin necesidad de un identificador único que lo defina por sí mismo. Sin embargo, en este modelo, se le ha asignado un id, lo que podría contradecir la definición pura de Value Object en DDD.
    
    **Clarificación y Uso Correcto de Value Objects**
    
    Actualmente, algunas clases como `Education` y `WorkExperience` tienen identificadores únicos 1, lo que las clasifica como entidades. Sin embargo, en muchos casos, estos podrían ser tratados como Value Objects dentro del contexto de un Candidate.
    
    **Mejora Propuesta:**
    
    - Eliminar los identificadores únicos de las clases que deberían ser Value Objects. Esto implica cambiar la forma en que se manejan estas clases en la base de datos, posiblemente incorporándolas como parte de los documentos de Candidate si se usa una base de datos NoSQL, o manteniéndolas en tablas separadas pero sin tratarlas como entidades independientes en el dominio.
    </aside>
    
    *Versión mejorada*
    
    ```tsx
    
    ```
    
- **Agregados:** Conjuntos de objetos que deben ser tratados como una unidad.
    
    *Antes*
    
    ```tsx
     // Datos del candidato y su educación manejados por separado.
    const candidate = { id: 1, name: 'John Doe' };
    const educations = [{ candidateId: 1, institution: 'University' }];
    ```
    
    *Después*
    
    ```tsx
    export class Candidate {
        id?: number;
        firstName: string;
        lastName: string;
        email: string;
        educations: Education[];
        constructor(data: any) {
            this.id = data.id;
            this.firstName = data.firstName;
            this.lastName = data.lastName;
            this.email = data.email;
            this.educations = data.educations.map(edu => new Education(edu));
        }
    }
    ```
    
    <aside>
    💡 **Explicación**: `Candidate` actúa como un agregado que contiene `Education`, `WorkExperience`, `Resume`, y `Application`. `Candidate` es la raíz del agregado, ya que las otras entidades tienen sentido solo en relación con un candidato.
    
    **Recomendación:** Los agregados deben ser diseñados cuidadosamente para garantizar que todas las operaciones dentro del límite del agregado mantengan la consistencia.
    
    **Mejora Propuesta:**
    
    - Revisar y posiblemente limitar las operaciones que modifican los objetos dentro del agregado de `Candidate`. Por ejemplo, operaciones que afectan a `Education` y `WorkExperience` deberían ser manejadas a través de la raíz del agregado, `Candidate`, para mantener la integridad y el encapsulamiento.
    </aside>
    
    *Versión mejorada*
    
    ```tsx
    
    ```
    
- **Repositorios:** Interfaces que proporcionan acceso a agregados y entidades.
    
    *Antes*
    
    ```tsx
    // Acceso directo a la base de datos sin abstracción.
    function getCandidateById(id) {
        return database.query('SELECT * FROM candidates WHERE id = ?', [id]);
    }
    ```
    
    Explicación:
    
    *Después*
    
    ```tsx
    export class CandidateRepository {
        async findById(id: number): Promise<Candidate | null> {
            const data = await prisma.candidate.findUnique({ where: { id } });
            return data ? new Candidate(data) : null;
        }
    }
    ```
    
    <aside>
    💡 **Explicación**: `CandidateRepository` proporciona una interfaz clara para acceder a los datos de los candidatos, encapsulando la lógica de acceso a la base de datos.
    
    **Recomendación:** Los repositorios están parcialmente implementados pero podrían ser extendidos para encapsular completamente todas las operaciones de acceso a datos relacionadas con sus entidades.
    
    **Mejora Propuesta:**
    
    - Desarrollar interfaces de repositorio completas para cada entidad y agregado, asegurando que toda interacción con la base de datos para esas entidades pase por el repositorio. Esto podría incluir métodos para crear, actualizar, eliminar y buscar entidades.
    - Implementar métodos de repositorio que manejen colecciones de entidades, como listas de Candidates, que puedan ser filtradas o modificadas en masa.
    </aside>
    
- **Servicios de Dominio:** Lógica de negocio que no pertenece naturalmente a una entidad o valor.
    
    *Antes*
    
    ```tsx
    // Funciones sueltas para manejar la lógica de negocio.
    function calculateAge(candidate) {
        const today = new Date();
        const birthDate = new Date(candidate.birthDate);
        let age = today.getFullYear() - birthDate.getFullYear();
        const m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }
        return age;
    }
    ```
    
    *Después*
    
    ```tsx
    export class CandidateService {
      static calculateAge(candidate: Candidate): number {
          const today = new Date();
          const birthDate = new Date(candidate.birthDate);
          let age = today.getFullYear() - birthDate.getFullYear();
          const m = today.getMonth() - birthDate.getMonth();
          if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
              age--;
          }
          return age;
      }
    }
    ```
    
    <aside>
    💡 **Explicación**: `CandidateService` encapsula la lógica de negocio relacionada con los candidatos, como calcular la edad, proporcionando un punto centralizado y coherente para manejar estas operaciones.
    
    </aside>
    
- **Otra recomendaciones**
    
    **Uso de Factories**
    
    Las factories son útiles en DDD para encapsular la lógica de creación de objetos complejos, asegurando que todos los objetos creados cumplan con las reglas del dominio desde el momento de su creación.
    
    <aside>
    💡 **Mejora Propuesta:** Implementar factories para la creación de entidades y agregados, especialmente aquellos que son complejos y requieren de una configuración inicial específica que cumpla con las reglas del negocio.
    
    </aside>
    
    **Mejora en la Modelación de Relaciones**
    
    Las relaciones entre entidades y agregados deben ser claras y consistentes con las reglas del negocio.
    
    <aside>
    💡 **Mejora Propuesta:** Revisar y posiblemente rediseñar las relaciones entre entidades para asegurar que reflejen con precisión las necesidades y reglas del dominio. Esto puede incluir la eliminación de relaciones innecesarias o la adición de nuevas relaciones que faciliten operaciones del negocio.
    
    </aside>
    
    **Integración de Eventos de Dominio**
    
    Los eventos de dominio son una parte importante de DDD y pueden ser utilizados para manejar efectos secundarios de las operaciones de dominio de manera desacoplada.
    
    <aside>
    💡 **Mejora Propuesta:** Implementar un sistema de eventos de dominio que permita a las entidades y agregados publicar eventos que otros componentes del sistema pueden manejar sin estar fuertemente acoplados a las entidades que los generan.
    
    </aside>
    

## **2. Principios SOLID y DRY**

**SOLID**

Los principios SOLID son cinco principios de diseño orientados a objetos que ayudan a crear sistemas más comprensibles, flexibles y mantenibles.

- **S - Single Responsibility Principle (SRP):** Cada clase debe tener una única responsabilidad o razón para cambiar.
    
    *Antes*
    
    ```tsx
    // Un método que maneja múltiples responsabilidades: validación y almacenamiento de datos.
    function processCandidate(candidate) {
        if (!candidate.email.includes('@')) {
            console.error('Email inválido');
            return;
        }
        database.save(candidate);
        console.log('Candidato guardado');
    }
    ```
    
    *Después*
    
    ```tsx
    export class Candidate {
      // La clase ahora solo se encarga de la lógica relacionada con el candidato.
      validateEmail() {
          if (!this.email.includes('@')) {
              throw new Error('Email inválido');
          }
      }
    
      save() {
          this.validateEmail();
          prisma.candidate.create(this);
      }
    }
    ```
    
    <aside>
    💡 **Explicación**: La clase `Candidate` ahora tiene métodos separados para validar el email y guardar la información, cumpliendo con el principio de responsabilidad única.
    
    **Observation:**
    
    The Candidate class in `backend/src/domain/models/Candidate.ts` handles both the business logic and data access logic.
    
    **Recommendation:**
    
    Separate data access logic into a repository layer to adhere more closely to SRP.
    
    </aside>
    
    *Improvement Example:*
    
    Create a `CandidateRepository` class for database interactions.
    
    ```
    class CandidateRepository {
        async save(candidateData: any) {
            // Database interaction logic here
        }
    }
    ```
    
- **O - Open/Closed Principle (OCP):** Las entidades de software deben estar abiertas para extensión, pero cerradas para modificación.
    
    *Antes*
    
    ```tsx
    // Modificación directa de la clase para añadir funcionalidad.
    class Candidate {
        saveToDatabase() {
            // código para guardar en la base de datos
        }
        // Para añadir nueva funcionalidad, modificamos la clase directamente.
        sendEmail() {
            // código para enviar un email
        }
    }
    ```
    
    *Después*
    
    ```tsx
    export class Candidate {
      saveToDatabase() {
          // código para guardar en la base de datos
      }
    }
    // Extendemos la funcionalidad sin modificar la clase existente.
    class CandidateWithEmail extends Candidate {
      sendEmail() {
          // código para enviar un email
      }
    }
    ```
    
    <aside>
    💡 **Explicación**: La funcionalidad de enviar un email se extiende en una subclase, manteniendo la clase original cerrada para modificaciones pero abierta para extensiones.
    
    **Observation:**
    
    The `addCandidate` function in `backend/src/application/services/candidateService.ts` directly instantiates `Candidate`, `Education`, `WorkExperience`, and `Resume` classes.
    
    **Recommendation:**
    
    Use factory methods to create instances, allowing for easier extension without modifying existing code.
    
    </aside>
    
    *Improvement Example:*
    
    Implement a factory method for creating a Candidate.
    
    ```tsx
    class CandidateFactory {
        static createCandidate(data: any): Candidate {
            return new Candidate(data);
        }
    }
    ```
    
- **L - Liskov Substitution Principle (LSP):** Los objetos de una clase derivada deben ser reemplazables por objetos de la clase base sin alterar el funcionamiento del programa.
    
    *Antes*
    
    ```tsx
    // Subclase que no puede reemplazar completamente a su clase base.
    class TemporaryCandidate extends Candidate {
        saveToDatabase() {
            throw new Error("Temporary candidates can't be saved.");
        }
    }
    ```
    
    *Después*
    
    ```tsx
    class TemporaryCandidate extends Candidate {
      saveToDatabase() {
          // Implementación adecuada que permite guardar o manejar temporalmente.
          console.log("Handled temporarily");
      }
    }
    ```
    
    <aside>
    💡 **Explicación**: `TemporaryCandidate` ahora proporciona una implementación adecuada que respeta el contrato de la clase base, permitiendo su sustitución sin errores.
    
    **Observation:**
    
    Currently, there is no inheritance in use where LSP could be violated. The project uses composition over inheritance, which generally supports LSP.
    
    **Recommendation:**
    
    Continue using composition to avoid LSP violations and ensure that any future inheritance structures allow derived classes to substitute their base classes without altering how the program works.
    
    </aside>
    
- **I - Interface Segregation Principle (ISP):** Muchas interfaces específicas son mejores que una sola interfaz general.
    
    *Antes*
    
    ```tsx
    // Una interfaz grande que los clientes pequeños no usan completamente.
    interface CandidateOperations {
        save();
        validate();
        sendEmail();
        generateReport();
    }
    ```
    
    *Después*
    
    ```tsx
    interface SaveOperation {
        save();
    }
    
    interface EmailOperations {
        sendEmail();
    }
    
    interface ReportOperations {
        generateReport();
    }
    
    class Candidate implements SaveOperation, EmailOperations {
        save() {
            // implementación
        }
    
        sendEmail() {
            // implementación
        }
    }
    ```
    
    <aside>
    💡 **Explicación**: Las interfaces están segregadas en operaciones más pequeñas, permitiendo que las clases implementen solo las interfaces que necesitan.
    
    **Observation:**
    
    The project does not currently use TypeScript interfaces extensively to enforce contracts for classes.
    
    **Recommendation:**
    
    Define more granular interfaces for service classes to ensure they only implement the methods they need.
    
    </aside>
    
    *Improvement Example:*
    
    Define an interface for candidate-related operations.
    
    ```tsx
    interface ICandidateService {
        addCandidate(candidateData: any): Promise<Candidate>;
        findCandidateById(id: number): Promise<Candidate | null>;
    }
    ```
    
- **D - Dependency Inversion Principle (DIP):** Los módulos de alto nivel no deben depender de módulos de bajo nivel; ambos deben depender de abstracciones.
    
    *Antes*
    
    ```tsx
    // Dependencia directa de una implementación concreta.
    class Candidate {
        private database = new MySQLDatabase();
        save() {
            this.database.save(this);
        }
    }
    ```
    
    *Después*
    
    ```tsx
    interface Database {
        save(candidate: Candidate);
    }
    
    class Candidate {
        private database: Database;
        constructor(database: Database) {
            this.database = database;
        }
    
        save() {
            this.database.save(this);
        }
    }
    ```
    
    <aside>
    💡 **Explicación**: `Candidate` ahora depende de una abstracción (Database), no de una implementación concreta, lo que facilita la flexibilidad y la prueba del código.
    
    **Observation:**
    
    Classes like Candidate directly depend on the concrete PrismaClient for database operations.
    
    **Recommendation:**
    
    Use dependency injection to invert the dependency, relying on abstractions rather than concrete implementations.
    
    </aside>
    
    *Improvement Example:*
    
    Inject `PrismaClient` through the constructor or a setter method.
    
    ```tsx
    constructor(data: any, private prismaClient: PrismaClient) {
        // Initialization code
    }
    ```
    

**DRY (Don't Repeat Yourself)**

El principio DRY se centra en la reducción de duplicación en el código. Cada pieza de conocimiento debe tener una representación única, inequívoca y autoritativa dentro de un sistema.

*Antes*

```tsx
// Código repetido para validar emails en múltiples funciones.
function saveCandidate(candidate) {
    if (!candidate.email.includes('@')) {
        throw new Error('Email inválido');
    }
    // guardar lógica
}

function updateCandidate(candidate) {
    if (!candidate.email.includes('@')) {
        throw new Error('Email inválido');
    }
    // actualizar lógica
}
```

*Después*

```tsx
export class Candidate {
    validateEmail() {
        if (!this.email.includes('@')) {
            throw new Error('Email inválido');
        }
    }

    save() {
        this.validateEmail();
        // guardar lógica
    }

    update() {
        this.validateEmail();
        // actualizar lógica
    }
}
```

<aside>
💡 **Explicación**: La validación del email se centraliza en un solo método `validateEmail`, eliminando la duplicación de código en las funciones save y update.

**Observation:**

The methods for saving entities like `Candidate`, `Education`, `WorkExperience`, and `Resume` contain repetitive logic for handling database operations.

**Recommendation:**

Abstract common database operation logic into a reusable function or class.

</aside>

Improvement Example:

Create a generic database handler.

```tsx
class DatabaseHandler {
    static async saveEntity(entity: any) {
        // Generic save logic
    }
}
```

[**Patrones de Diseño**](https://www.notion.so/Patrones-de-Dise-o-e006deb558f34f259a68b509f67566c7?pvs=21)

[Prompt: Manifesto Buenas Prácticas](https://www.notion.so/Prompt-Manifesto-Buenas-Pr-cticas-ff4938d307174a4bbdcfc5fd2dbbbe6d?pvs=21)

[Contrato Buenas Prácticas](https://www.notion.so/Contrato-Buenas-Pr-cticas-dd592dd96989406eb226bb240e495f27?pvs=21)
