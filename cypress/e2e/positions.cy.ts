describe('PositionsDetails E2E Tests', () => {
  beforeEach(() => {
    // Intercepta las llamadas API y asigna un alias a cada una
    cy.intercept('GET', 'http://localhost:3010/positions/*/interviewFlow').as('getInterviewFlow');
    cy.intercept('GET', 'http://localhost:3010/positions/*/candidates').as('getCandidates');

    // Visita la página que carga los datos
    cy.visit('http://localhost:3000/positions/1');
  });

  it('should display the position title correctly', () => {
    // Espera a que ambas llamadas API se completen
    cy.wait(['@getInterviewFlow', '@getCandidates']);

    // Realiza las verificaciones después de que los datos estén cargados
    cy.get('h2').should('contain', 'Senior Full-Stack Engineer');
  });

  it('should display columns for each hiring phase', () => {
      const phases = ['Initial Screening', 'Technical Interview', 'Manager Interview']; // Ajusta las fases según tu aplicación
      phases.forEach(phase => {
        // Busca un Card.Header que contenga el texto de la fase
        cy.contains('.card-header', phase).should('be.visible');
      });
  });

  it('should display candidate cards in the correct columns', () => {
      const candidates = [
          { id: '1', name: 'John Doe', phase: 'Technical Interview' },
          { id: '2', name: 'Jane Smith', phase: 'Technical Interview' },
          { id: '3', name: 'Carlos García', phase: 'Initial Screening' },
      ];

    candidates.forEach(candidate => {
      // Find the CandidateCard with the candidate's name and check if it is placed in the correct StageColumn
      cy.contains('.card-header', candidate.phase).parents('.card').within(() => {
          cy.get('.mb-2').contains('.card-title', candidate.name).should('be.visible');
      });

    });
  });

  it('should allow dragging a candidate card to a new phase and update backend', () => {
    const candidateId = '1'; // Asume un ID de candidato
    const sourcePhase = '1';
    const targetPhase = '2';
    // Use the custom command 'dragAndDrop' to simulate dragging the candidate card
    cy.get(`[data-cy=candidate-card-${candidateId}]`).as('candidateCard');
    cy.get(`[data-cy=phase-column-${sourcePhase}]`).as('sourceColumn');
    cy.get(`[data-cy=phase-column-${targetPhase}]`).as('targetColumn');

    // Perform the drag and drop operation
    cy.get('@candidateCard').then(candidateCard => {
      cy.get('@targetColumn').then(targetColumn => {
        candidateCard.trigger('dragstart');
        targetColumn.trigger('drop');
      });
    });

    // Verify the candidate card is now in the target column
    cy.get('@targetColumn').within(() => {
      cy.get('@candidateCard').then(candidateCard => {
        expect(candidateCard).to.exist;
      });
    });


  });



});
